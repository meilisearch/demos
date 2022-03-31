
# `nikita.ssh.root`

Prepare the system to receive password-less root login with SSL/TLS keys.

Prior executing this handler, a user with appropriate sudo permissions must be 
created. The script will use those credentials
to loggin and will try to become root with the "sudo" command. Use the "command" 
property if you must use a different command (such as "sudo su -").

Additionnally, it disables SELINUX which require a restart. The restart is 
handled by Masson and the installation procedure will continue as soon as an 
SSH connection is again available.

## Example

```js
const {$status} = await nikita.ssh.root({
  "username": "vagrant",
  "private_key_path": "/home/monsieur/.vagrant.d/insecure_private_key"
  "public_key_path": "~/.ssh/id_rsa.pub"
})
console.info(`Public key was updoaded for root user: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'command':
            oneOf: [{type: 'string'}, {typeof: 'function'}]
          'host':
            type: 'string'
            # oneOf: [{format: 'ipv4'}, {format: 'hostname'}]
            default: 'root'
            description: '''
            Command used to become the root user on the remote server, for example
            `su -`.
            '''
          'password':
            type: 'string'
            description: '''
            Password of the user with sudo permissions to establish the SSH
            connection  if no private key is provided.
            '''
          'port':
            type: 'integer'
            default: 22
            description: '''
            '''
          'private_key':
            type: 'string'
            description: '''
            Private key of the user with sudo permissions to establish the SSH
            connection if `password` is not provided.
            '''
          'private_key_path':
            type: 'string'
            description: '''
            Local file location of the private key of the user with sudo
            permissions and used to establish the SSH connection if `password` and
            `private_key` are not provided.
            '''
          'public_key':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Public key added to "authorized_keys" to enable the root user.
            '''
          'public_key_path':
            type: 'string'
            description: '''
            Local path to the public key added to "authorized_keys" to enable the
            root  user.
            '''
          'selinux':
            oneOf: [
              {type: 'string', enum: ['disabled', 'enforcing', 'permissive']},
              {type: 'boolean'}
            ]
            default: 'permissive'
            description: '''
            Username of the user with sudo permissions to establish the SSH
            connection.
            '''
          'username':
            type: 'string'
            description: '''
            Username of the user with sudo permissions to establish the SSH
            connection.
            '''

## Handler

    handler = ({metadata, config, tools: {log}}) ->
      config.host ?= config.ip
      # config.command ?= 'su -'
      config.username ?= null
      config.password ?= null
      config.selinux ?= false
      config.selinux = 'permissive' if config.selinux is true
      # Validation
      throw Error "Invalid option \"selinux\": #{config.selinux}" if config.selinux and config.selinux not in ['enforcing', 'permissive', 'disabled']
      rebooting = false
      # Read public key if option is a path
      if config.public_key_path and not config.public_key
        location = await utils.tilde.normalize config.public_key_path
        try
          {data: config.public_key} = await fs.readFile location, 'ascii'
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      # Read private key if option is a path
      if config.private_key_path and not config.private_key
        log message: "Read Private Key: #{JSON.stringify config.private_key_path}", level: 'DEBUG'
        location = await utils.tilde.normalize config.private_key_path
        try
          {data: config.private_key} = await fs.readFile location, 'ascii'
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      await @call ->
        log message: "Connecting", level: 'DEBUG'
        conn = unless metadata.dry
        then await connect config
        else null
        log message: "Connected", level: 'INFO'
        command = []
        command.push """
        sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
        """
        command.push """
        mkdir -p /root/.ssh; chmod 700 /root/.ssh;
        echo '#{config.public_key}' >> /root/.ssh/authorized_keys;
        """ if config.public_key
        command.push """
        sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
        selinux="#{config.selinux or ''}";
        if [ -n "$selinux" ] && [ -f /etc/selinux/config ] && grep ^SELINUX="$selinux" /etc/selinux/config;
        then
          sed -i.back "s/^SELINUX=enforcing/SELINUX=$selinux/" /etc/selinux/config;
          ( reboot )&
          exit 2;
        fi;
        """
        command = command.join '\n'
        if config.username isnt 'root'
          command = command.replace /\n/g, ' '
          if typeof config.command is 'function'
            command = config.command command
          else if typeof config.command is 'string'
            command = "#{config.command} #{command}"
          else
            config.command = 'sudo '
            config.command += "-u #{config.user} " if config.user
            config.command = "echo -e \"#{config.password}\\n\" | #{config.command} -S " if config.password
            config.command += "-- sh -c \"#{command}\""
            command = config.command
        log message: "Enable Root Access", level: 'DEBUG'
        log message: command, type: 'stdin'
        unless metadata.dry
          child = exec
            ssh: conn
            command: command
          , (err) =>
            if err?.code is 2
              log message: "Root Access Enabled", level: 'WARN'
              err = null
              rebooting = true
            else throw err
          child.stdout.on 'data', (data) =>
            log message: data, type: 'stdout'
          child.stdout.on 'end', (data) =>
            log message: null, type: 'stdout'
          child.stderr.on 'data', (data) =>
            log message: data, type: 'stderr'
          child.stderr.on 'end', (data) =>
            log message: null, type: 'stderr'
      await @call $if: rebooting, $retry: true, $sleep: 3000, ->
        conn = await connect config
        conn.end()

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    fs = require('fs').promises
    connect = require 'ssh2-connect'
    exec = require 'ssh2-exec'
    utils = require '../../utils'
