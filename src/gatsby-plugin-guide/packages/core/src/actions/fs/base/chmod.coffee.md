
# `nikita.fs.base.chmod`

Change permissions of a file.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'mode':
            type: ['string', 'integer']
            filemode: true
            description: '''
            File mode. Modes may be absolute or symbolic. An absolute mode is
            an octal number. A symbolic mode is a string with a particular syntax
            describing `who`, `op` and `perm` symbols.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the file which permission will change.
            '''
        required: ['mode', 'target']

## Handler

    handler = ({config}) ->
      mode = if typeof config.mode is 'number'
      then config.mode.toString(8).substr(-4)
      else config.mode
      @execute "chmod #{mode} #{config.target}"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions
