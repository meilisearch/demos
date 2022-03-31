
# `nikita.fs.base.rename`

Change the name or location of a file.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'source':
            type: 'string'
            description: '''
            Location of the file to rename.
            '''
          'target':
            type: 'string'
            description: '''
            New name of the file.
            '''
        required: ['source', 'target']

## Handler

    handler = ({config}) ->
      await @execute
        command: "mv #{config.source} #{config.target}"
        trim: true

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions
