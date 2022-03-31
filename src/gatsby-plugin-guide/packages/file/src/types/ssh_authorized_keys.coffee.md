
# `nikita.file.types.ssh_authorized_keys`

Note, due to the restrictive permission imposed by sshd on the parent directory,
this action will not attempt to create nor modify the parent directory and will
throw an Error if it does not exists.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            type: 'string'
            description: '''
            File group name or group id.
            '''
          'keys':
            type: 'array'
            description: '''
            Array containing the public keys.
            '''
          'merge':
            type: 'boolean'
            description: '''
            Read the target if it exists and merge its content.
            '''
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'target':
            type: 'string'
            description: '''
            File to write, default to "/etc/pacman.conf".
            '''
          'uid':
            type: 'string'
            description: '''
            File user name or user id.
            '''
        required: ['target', 'keys']

## Handler

    handler = ({config}) ->
      await @fs.assert
        target: path.dirname config.target
      if config.merge
        await @file
          target: config.target
          write: for key in config.keys
            match: new RegExp ".*#{utils.regexp.escape key}.*", 'mg'
            replace: key
            append: true
          uid: config.uid
          gid: config.gid
          mode: config.mode
          eof: true
      else
        await @file
          target: config.target
          content: config.keys.join '\n'
          uid: config.uid
          gid: config.gid
          mode: config.mode
          eof: true
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    path = require 'path'
    utils = require '../utils'
