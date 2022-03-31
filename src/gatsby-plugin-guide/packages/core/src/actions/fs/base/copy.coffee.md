
# `nikita.fs.base.copy`

Change permissions of a file.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'source':
            type: 'string'
            description: '''
            Source file to be copied.
            '''
          'target':
            type: 'string'
            description: '''
            Destination file where to copy the source file.
            '''
        required: ['source', 'target']

## Handler

    handler = ({config}) ->
      try
        await @execute """
          [ ! -d `dirname "#{config.target}"` ] && exit 2
          cp #{config.source} #{config.target}
          """
      catch err
        if err.exit_code is 2
          err = errors.NIKITA_FS_COPY_TARGET_ENOENT config: config, err: err
        throw err

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions

## Errors

    errors =
      NIKITA_FS_COPY_TARGET_ENOENT: ({config, err}) ->
        utils.error 'NIKITA_FS_COPY_TARGET_ENOENT', [
          'target parent directory does not exists or is not a directory,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'open'
          path: config.target

## Dependencies

    utils = require '../../../utils'
