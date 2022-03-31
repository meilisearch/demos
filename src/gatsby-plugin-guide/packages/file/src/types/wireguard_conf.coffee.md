
# `nikita.file.types.wireguard_conf`

Pacman is a package manager utility for Arch Linux. The file is usually located 
in "/etc/pacman.conf".

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'rootdir':
            type: 'string'
            description: '''
            Path to the mount point corresponding to the root directory, optional.
            '''
          'interface':
            type: 'string'
            description: '''
            Interface
            '''
          'target':
            type: 'string'
            description: '''
            Destination file.
            '''

## Handler

    handler = ({config}) ->
      config.target ?= "/etc/wireguard/#{config.interface}.conf"
      config.target = "#{path.join config.rootdir, config.target}" if config.rootdir
      await @file.ini
        parse: utils.ini.parse_multi_brackets
        stringify: utils.ini.stringify_multi_brackets
        indent: ''
      , config

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    path = require 'path'
    utils = require '../utils'
