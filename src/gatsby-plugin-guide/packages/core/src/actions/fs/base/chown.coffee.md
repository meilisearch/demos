
# `nikita.fs.base.chown`

Change ownership of a file.

## Hooks

    on_action = ({config, metadata}) ->
      # String to integer coercion
      config.uid = parseInt config.uid if (typeof config.uid is 'string') and /\d+/.test config.uid
      config.gid = parseInt config.gid if (typeof config.gid is 'string') and /\d+/.test config.gid

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            type: ['integer', 'string']
            description: '''
            Unix group name or id who owns the target file.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the file which permissions will change.
            '''
          'uid':
            type: ['integer', 'string']
            description: '''
            Unix user name or id who owns the target file.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      # Normalization
      config.uid = null if config.uid is false
      config.gid = null if config.gid is false
      # Validation
      throw Error "Missing one of uid or gid option" unless config.uid? or config.gid?
      await @execute [
        "chown #{config.uid} #{config.target}" if config.uid?
        "chgrp #{config.gid} #{config.target}" if config.gid?
      ].join '\n'

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions
