
# `nikita.tools.apm.uninstall`

Remove one or more apm packages.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'array', items: type: 'string'
            description: '''
            Name of the package(s) to install.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      config.name = config.name.map (pkg) -> pkg.toLowerCase()
      installed = []
      {stdout} = await @execute
        $shy: true
        command: "apm list --installed --json"
      pkgs = JSON.parse stdout
      installed = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
      # Uninstall
      uninstall = config.name.filter (pkg) -> pkg in installed
      if uninstall.length
        await @execute
          command: "apm uninstall #{config.name.join ' '}"
        log message: "APM Uninstalled Packages: #{config.name.join ', '}"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
