
# `nikita.fs.base.rmdir`

Delete a directory.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'recursive':
            type: 'boolean'
            description: '''
            Attempt to remove the file hierarchy rooted in the directory.
            Attempting to remove a non-empty directory without the `recursive`
            config will throw an Error.
            '''
          'target':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Location of the directory to remove.
            '''
        required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      try
        await @execute
          command: [
            "[ ! -d #{escapeshellarg config.target} ] && exit 2"
            unless config.recursive
              "rmdir #{escapeshellarg config.target}"
            else
              "rm -R #{escapeshellarg config.target}"
          ].join '\n'
        log message: "Directory successfully removed", level: 'INFO'
      catch err
        if err.exit_code is 2
          err = errors.NIKITA_FS_RMDIR_TARGET_ENOENT config: config, err: err
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
      NIKITA_FS_RMDIR_TARGET_ENOENT: ({config, err}) ->
        utils.error 'NIKITA_FS_RMDIR_TARGET_ENOENT', [
          'fail to remove a directory, target is not a directory,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'rmdir'
          path: config.target

## Dependencies

    utils = require '../../../utils'
    {escapeshellarg} = utils.string
