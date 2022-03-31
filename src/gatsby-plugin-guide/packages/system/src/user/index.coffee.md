
# `nikita.system.user`

Create or modify a Unix user.

If the user home is provided, its parent directory will be created with root 
ownerships and 0644 permissions unless it already exists.

## Callback parameters

* `$status`   
  Value is "true" if user was created or modified.

## Example

```js
const {$status} = await nikita.system.user({
  name: 'a_user',
  system: true,
  uid: 490,
  gid: 10,
  comment: 'A System User'
})
console.log(`User created: ${$status}`)
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
you are a member of the "wheel" group (gid of "10") with the command
`id a\_user` producing an output similar to 
"uid=490(hive) gid=10(wheel) groups=10(wheel)".

## Hooks

    on_action = ({config}) ->
      switch config.shell
        when true
          config.shell = '/bin/sh'
        when false
          config.shell = '/sbin/nologin'
      config.groups = config.groups.split ',' if typeof config.groups is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'comment':
            type: 'string'
            description: '''
            Short description of the login.
            '''
          'expiredate':
            type: 'integer'
            description: '''
            The date on which the user account is disabled.
            '''
          'gid':
            type: 'integer'
            description: '''
            Group name or number of the user´s initial login group.
            '''
          'groups':
            type: 'array'
            items: type: 'string'
            description: '''
            List of supplementary groups which the user is also a member of.
            '''
          'home':
            type: 'string'
            description: '''
            Value for the user´s login directory, default to the login name
            appended to "BASE_DIR".
            '''
          'inactive':
            type: 'integer'
            description: '''
            The number of days after a password has expired before the account
            will be disabled.
            '''
          'name':
            type: 'string'
            description: '''
            Login name of the user.
            '''
          'no_home_ownership':
            type: 'boolean'
            description: '''
            Disable ownership on home directory which default to the "uid" and
            "gid" config, default is "false".
            '''
          'password':
            type: 'string'
            description: '''
            The unencrypted password.
            '''
          'password_sync':
            type: 'boolean'
            default: true
            description: '''
            Synchronize password
            '''
          'shell':
            # oneOf: [
            #   type: 'boolean'
            # ,
            #   type: 'string'
            # ]
            type: ['boolean', 'string']
            default: '/bin/sh'
            description: '''
            Path to the user shell, set to "/sbin/nologin" if `false` and "/bin/sh"
            if `true` or `undefined`.
            '''
          'skel':
            type: 'string'
            description: '''
            The skeleton directory, which contains files and directories to be
            copied in the user´s home directory, when the home directory is
            created by useradd.
            '''
          'system':
            type: 'boolean'
            description: '''
            Create a system account, such user are not created with a home by
            default, set the "home" option if we it to be created.
            '''
          'uid':
            type: 'integer'
            description: '''
            Numerical value of the user´s ID, must not exist.
            '''
        required: ['name']

## Handler

    handler = ({metadata, config, tools: {log}}) ->
      log message: "Entering user", level: 'DEBUG'
      config.system ?= false
      config.gid ?= null
      config.password_sync ?= true
      throw Error "Invalid option 'shell': #{JSON.strinfigy config.shell}" if config.shell? typeof config.shell isnt 'string'
      user_info = groups_info = null
      {users} = await @system.user.read()
      user_info = users[config.name]
      log if user_info
      then message: "Got user information for #{JSON.stringify config.name}", level: 'DEBUG', module: 'nikita/lib/system/group'
      else message: "User #{JSON.stringify config.name} not present", level: 'DEBUG', module: 'nikita/lib/system/group'
      # Get group information if
      # * user already exists
      # * we need to compare groups membership
      {groups} = await @system.group.read
        $if: user_info and config.groups
      groups_info = groups
      log message: "Got group information for #{JSON.stringify config.name}", level: 'DEBUG' if groups_info
      if config.home
        @fs.mkdir
          $unless_exists: path.dirname config.home
          target: path.dirname config.home
          uid: 0
          gid: 0
          mode: 0o0644 # Same as '/home'
      unless user_info
        await @execute [
          code_skipped: 9
          command: [
            'useradd'
            '-r' if config.system
            '-M' unless config.home
            '-m' if config.home
            "-d #{config.home}" if config.home
            "-s #{config.shell}" if config.shell
            "-c #{utils.string.escapeshellarg config.comment}" if config.comment
            "-u #{config.uid}" if config.uid
            "-g #{config.gid}" if config.gid
            "-e #{config.expiredate}" if config.expiredate
            "-f #{config.inactive}" if config.inactive
            "-G #{config.groups.join ','}" if config.groups
            "-k #{config.skel}" if config.skel
            "#{config.name}"
            ].join ' '
        ,
          $if: config.home
          command: "chown #{config.name}. #{config.home}"
        ]
        log message: "User defined elsewhere than '/etc/passwd', exit code is 9", level: 'WARN'
      else
        changed = []
        for k in ['uid', 'home', 'shell', 'comment', 'gid']
          changed.push k if config[k]? and user_info[k] isnt config[k]
        if config.groups then for group in config.groups
          throw Error "Group does not exist: #{group}" unless groups_info[group]
          changed.push 'groups' if groups_info[group].users.indexOf(config.name) is -1
        log if changed.length
        then message: "User #{config.name} modified", level: 'WARN', module: 'nikita/lib/system/user/add'
        else message: "User #{config.name} not modified", level: 'DEBUG', module: 'nikita/lib/system/user/add'
        try
          await @execute
            $if: changed.length
            command: [
              'usermod'
              "-d #{config.home}" if config.home
              "-s #{config.shell}" if config.shell
              "-c #{utils.string.escapeshellarg config.comment}" if config.comment?
              "-g #{config.gid}" if config.gid
              "-G #{config.groups.join ','}" if config.groups
              "-u #{config.uid}" if config.uid
              "#{config.name}"
            ].join ' '
        catch err
          if err.exit_code is 8
            throw Error "User #{config.name} is logged in"
          else throw err
        if config.home and (config.uid or config.gid)
          await @fs.chown
            $if_exists: config.home
            $unless: config.no_home_ownership
            target: config.home
            uid: config.uid
            gid: config.gid
      # TODO, detect changes in password
      # echo #{config.password} | passwd --stdin #{config.name}
      if config.password_sync and config.password
        {$status} = await @execute
          command: """
          hash=$(echo #{config.password} | openssl passwd -1 -stdin)
          usermod --pass="$hash" #{config.name}
          """
          # arch_chroot: config.arch_chroot
          # rootdir: config.rootdir
          # sudo: config.sudo
        log message: "Password modified", level: 'WARN' if $status

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'name'
        definitions: definitions

## Dependencies

    path = require 'path'
    utils = require '../utils'
