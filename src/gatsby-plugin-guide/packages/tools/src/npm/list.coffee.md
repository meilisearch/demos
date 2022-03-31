
# `nikita.tools.npm.list`

List all Node.js packages with NPM.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cwd':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/cwd'
          'global':
            type: 'boolean'
            default: false
            description: '''
            Upgrades global packages.
            '''
        if: properties: 'global': const: false
        then: required: ['cwd']

## Handler

    handler = ({config}) ->
      {stdout} = await @execute
        command: [
          'npm list'
          '--json'
          '--global' if config.global
        ].join ' '
        code: [0, 1]
        cwd: config.cwd
        stdout_log: false
      packages: JSON.parse(stdout).dependencies or {}
      
## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
