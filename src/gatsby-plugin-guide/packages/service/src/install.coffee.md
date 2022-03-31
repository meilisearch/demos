
# `nikita.service.install`

Install a service. Yum, Yay, Yaourt, Pacman and apt-get are supported.

## Output

* `$status`   
  Indicates if the service was installed.

## Example

```js
const {$status} = await nikita.service.install({
  name: 'ntp'
})
console.info(`Package installed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cache':
            type: 'boolean'
            description: '''
            Cache the list of installed and outdated packages.
            '''
          'cacheonly':
            type: 'boolean'
            description: '''
            Run the yum command entirely from system cache, don't update cache.
            '''
          'code_skipped':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/code_skipped'
            description: '''
            Error code to skip when using nikita.service.
            '''
          'installed':
            type: 'array', items: type: 'string'
            description: '''
            Cache a list of installed services. If an array, the service will be
            installed if a key of the same name exists; if anything else
            (default), no caching will take place.
            '''
          'name':
            type: 'string'
            description: '''
            Package name, required unless provided as main argument.
            '''
          'outdated':
            type: 'array', items: type: 'string'
            # oneOf: [
            #   {type: 'boolean'}
            #   {type: 'array', items: type: 'string'}
            # ]
            description: '''
            Cache a list of outdated services. If an array, the service will be
            updated if a key of the same name exists; If true, the option will be
            converted to an array with all the outdated service names as keys; if
            anything else (default), no caching will take place.
            '''
          'pacman_flags':
            type: 'array'
            default: []
            description: '''
            Additionnal flags passed to the `pacman -S` command.
            '''
          'yaourt_flags':
            type: 'array'
            default: []
            description: '''
            Additionnal flags passed to the `yaourt -S` command.
            '''
          'yay_flags':
            type: 'array'
            default: []
            description: '''
            Additionnal flags passed to the `yay -S` command.
            '''
        required: ['name']

## Handler

    handler = ({config, parent: {state}, tools: {log}}) ->
      # Config
      config.installed ?= state['nikita:execute:installed'] if config.cache
      config.outdated ?= state['nikita:execute:outdated'] if config.cache
      cacheonly = if config.cacheonly then '-C' else ''
      for flag, i in config.pacman_flags
        continue if /^-/.test flag
        config.pacman_flags[i] = "-#{flag}" if flag.length is 1
        config.pacman_flags[i] = "--#{flag}" if flag.length > 1
      for flag, i in config.yay_flags
        continue if /^-/.test flag
        config.yay_flags[i] = "-#{flag}" if flag.length is 1
        config.yay_flags[i] = "--#{flag}" if flag.length > 1
      for flag, i in config.yaourt_flags
        continue if /^-/.test flag
        config.yaourt_flags[i] = "-#{flag}" if flag.length is 1
        config.yaourt_flags[i] = "--#{flag}" if flag.length > 1
      # Start real work
      log message: "Install service #{config.name}", level: 'INFO'
      # List installed packages
      unless config.installed?
        try
          {$status, stdout} = await @execute
            $shy: true
            command: """
            if command -v yum >/dev/null 2>&1; then
              rpm -qa --qf "%{NAME}\n"
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qqe
            elif command -v apt-get >/dev/null 2>&1; then
              dpkg -l | grep \'^ii\' | awk \'{print $2}\'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
            """
            code_skipped: 1
            # arch_chroot: config.arch_chroot
            # arch_chroot_rootdir: config.arch_chroot_rootdir
            stdin_log: false
            stdout_log: false
          if $status
            log message: "Installed packages retrieved", level: 'INFO'
            config.installed = for pkg in utils.string.lines(stdout) then pkg
        catch err
          throw Error "Unsupported Package Manager" if err.exit_code is 2
      # List packages waiting for update
      if not config.outdated?
        try
          {$status, stdout} = await @execute
            $shy: true
            command: """
            if command -v yum >/dev/null 2>&1; then
              yum #{cacheonly} check-update -q | sed 's/\\([^\\.]*\\).*/\\1/'
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qu | sed 's/\\([^ ]*\\).*/\\1/'
            elif command -v apt-get >/dev/null 2>&1; then
              apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
            """
            code_skipped: 1
            # arch_chroot: config.arch_chroot
            # arch_chroot_rootdir: config.arch_chroot_rootdir
            stdin_log: false
            stdout_log: false
          if $status
            log message: "Outdated package list retrieved", level: 'INFO'
            config.outdated = utils.string.lines stdout.trim()
          else
            config.outdated = []
        catch err
          throw Error "Unsupported Package Manager" if err.exit_code is 2
      # Install the package
      if config.installed?.indexOf(config.name) is -1 or config.outdated?.indexOf(config.name) isnt -1
        try
          {$status} = await @execute
            command: """
            if command -v yum >/dev/null 2>&1; then
              yum install -y #{cacheonly} #{config.name}
            elif command -v yay >/dev/null 2>&1; then
              yay --noconfirm -S #{config.name} #{config.yay_flags.join ' '}
            elif command -v yaourt >/dev/null 2>&1; then
              yaourt --noconfirm -S #{config.name} #{config.yaourt_flags.join ' '}
            elif command -v pacman >/dev/null 2>&1; then
              pacman --noconfirm -S #{config.name} #{config.pacman_flags.join ' '}
            elif command -v apt-get >/dev/null 2>&1; then
              env DEBIAN_FRONTEND=noninteractive apt-get install -y #{config.name}
            else
              echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
              exit 2
            fi
            """
            code_skipped: config.code_skipped
            # arch_chroot: config.arch_chroot
            # arch_chroot_rootdir: config.arch_chroot_rootdir
          log if $status
          then message: "Package \"#{config.name}\" is installed", level: 'WARN', module: 'nikita/lib/service/install'
          else message: "Package \"#{config.name}\" is already installed", level: 'INFO', module: 'nikita/lib/service/install'
          # Enrich installed array with package name unless already there
          installedIndex = config.installed.indexOf config.name
          config.installed.push config.name if installedIndex is -1
          # Remove package name from outdated if listed
          if config.outdated
            outdatedIndex = config.outdated.indexOf config.name
            config.outdated.splice outdatedIndex, 1 unless outdatedIndex is -1
        catch err
          throw Error "Unsupported Package Manager: yum, yaourt, pacman, apt-get supported" if err.exit_code is 2
          throw utils.error 'NIKITA_SERVICE_INSTALL', [
              'failed to install package,'
              "name is `#{config.name}`"
            ], target: config.target
      if config.cache
        log message: "Caching installed on \"nikita:execute:installed\"", level: 'INFO'
        state['nikita:execute:installed'] = config.installed
        log message: "Caching outdated list on \"nikita:execute:outdated\"", level: 'INFO'
        state['nikita:execute:outdated'] = config.outdated
        $status: true

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
