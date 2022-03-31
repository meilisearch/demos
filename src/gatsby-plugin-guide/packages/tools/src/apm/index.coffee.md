
# `nikita.tools.apm`

Install Atom packages with APM.

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
          'upgrade':
            type: 'boolean'
            default: false
            description: '''
            Upgrade all packages.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      config.name = config.name.map (pkg) -> pkg.toLowerCase()
      outdated = []
      installed = []
      # Note, cant see a difference between update and upgrade after printing help
      {stdout} = await @execute
        $shy: true
        command: "apm outdated --json"
        # TODO: use the nikita.execute.json config
      pkgs = JSON.parse stdout
      outdated = pkgs.map (pkg) -> pkg.name.toLowerCase()
      if config.upgrade and outdated.length
        await @execute
          command: "apm upgrade --no-confirm"
        outdated = []
      {stdout} = await @execute
        $shy: true
        command: "apm list --installed --json"
        # TODO: use the nikita.execute.json config
      pkgs = JSON.parse stdout
      installed = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
      # Upgrade
      upgrade = config.name.filter (pkg) -> pkg in outdated
      if upgrade.length
        await @execute
          command: "apm upgrade #{upgrade.join ' '}"
        log message: "APM Updated Packages: #{upgrade.join ', '}"
      # Install
      install = config.name.filter (pkg) -> pkg not in installed
      if install.length
        await @execute
          command: "apm install #{install.join ' '}"
        log message: "APM Installed Packages: #{install.join ', '}"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
