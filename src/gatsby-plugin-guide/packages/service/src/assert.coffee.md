
# `nikita.service.assert`

Assert service information and status.

The option "action" takes 3 possible values: "start", "stop" and "restart". A 
service will only be restarted if it leads to a change of status. Set the value 
to "['start', 'restart']" to ensure the service will be always started.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'installed':
            type: 'boolean'
            description: '''
            Assert the package is installed.
            '''
          'name':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/name'
          'srv_name':
            type: 'string'
            description: '''
            Name used by the service utility, default to "name".
            '''
          'started':
            type: 'boolean'
            description: '''
            Assert if started.
            '''
          'stopped':
            type: 'boolean'
            description: '''
            Assert if stopped.
            '''
        required: ['name']

## Handler

    handler = ({config, metadata}) ->
      config.srv_name ?= config.name
      config.name = [config.name]
      # Assert a Package is installed
      if config.installed?
        try
          await @execute
            $shy: true
            command: """
            if command -v yum >/dev/null 2>&1; then
              rpm -qa --qf "%{NAME}\n" | grep '^#{config.name.join '|'}$'
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qqe | grep '^#{config.name.join '|'}$'
            elif command -v apt-get >/dev/null 2>&1; then
              dpkg -l | grep \'^ii\' | awk \'{print $2}\' | grep '^#{config.name.join '|'}$'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
            """
            # arch_chroot: config.arch_chroot
            # arch_chroot_rootdir: config.arch_chroot_rootdir
            stdin_log: true
            stdout_log: false
        catch err
          throw Error "Unsupported Package Manager" if err.exit_code is 2
          throw Error "Uninstalled Package: #{config.name}"
      # Assert a Service is started or stopped
      # Note, this doesnt check wether a service is installed or not.
      return unless config.started? or config.stopped?
      try
        {$status} = await @execute
          command: """
            ls \
              /lib/systemd/system/*.service \
              /etc/systemd/system/*.service \
              /etc/rc.d/* \
              /etc/init.d/* \
              2>/dev/null \
            | grep -w "#{config.srv_name}" || exit 3
            if command -v systemctl >/dev/null 2>&1; then
              systemctl status #{config.srv_name} || exit 3
            elif command -v service >/dev/null 2>&1; then
              service #{config.srv_name} status || exit 3
            else
              echo "Unsupported Loader" >&2
              exit 2
            fi
            """
          code: 0
          code_skipped: 3
          # arch_chroot: config.arch_chroot
          # arch_chroot_rootdir: config.arch_chroot_rootdir
      catch err
        throw Error "Unsupported Loader" if err.exit_code is 2
      if config.started?
        throw Error "Service Not Started: #{config.srv_name}" if config.started and not $status
        throw Error "Service Started: #{config.srv_name}" if not config.started and $status
      if config.stopped?
        throw Error "Service Not Stopped: #{config.srv_name}" if config.stopped and $status
        throw Error "Service Stopped: #{config.srv_name}" if not config.stopped and not $status

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
