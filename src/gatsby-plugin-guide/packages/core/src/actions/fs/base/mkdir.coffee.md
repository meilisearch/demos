
# `nikita.fs.base.mkdir`

Create a directory. Missing parent directories are created as required.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chown#/definitions/config/properties/gid'
          'mode':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chmod#/definitions/config/properties/mode'
          'target':
            type: 'string'
            description: '''
            Location of the directory to create.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chown#/definitions/config/properties/uid'
        required: ['target']

## Handler

    handler = ({config}) ->
      # Convert mode into a string
      config.mode = config.mode.toString(8).substr(-4) if typeof config.mode is 'number'
      try
        await @execute [
          "[ -d '#{config.target}' ] && exit 17"
          [
            'install'
            "-m '#{config.mode}'" if config.mode
            "-o '#{config.uid}'" if config.uid
            "-g '#{config.gid}'" if config.gid
            "-d '#{config.target}'"
          ].join ' '
        ].join '\n'
      catch err
        if err.exit_code is 17
          err = errors.NIKITA_FS_MKDIR_TARGET_EEXIST config: config
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
      NIKITA_FS_MKDIR_TARGET_EEXIST: ({config}) ->
        utils.error 'NIKITA_FS_MKDIR_TARGET_EEXIST', [
          'fail to create a directory,'
          'one already exists,'
          "location is #{JSON.stringify config.target}."
        ],
          error_code: 'EEXIST'
          errno: -17
          path: config.target_tmp or config.target # Native Node.js api doesn't provide path
          syscall: 'mkdir'

## Dependencies

    utils = require '../../../utils'
