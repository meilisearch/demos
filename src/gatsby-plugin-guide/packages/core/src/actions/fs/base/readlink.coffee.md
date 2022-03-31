
# `nikita.fs.base.readlink`

Read a link to retrieve its destination path.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'target':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Location of the link to read.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      {stdout} = await @execute
        command: "readlink #{config.target}"
      target: stdout.trim()

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions
