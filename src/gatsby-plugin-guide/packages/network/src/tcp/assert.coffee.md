
# `nikita.network.tcp.assert`

Assert a TCP or HTTP server is listening.

## Hooks

    on_action = ({config}) ->
      if config.server
        if Array.isArray config.server
        then config.server = utils.array.flatten config.server
        else config.server = [config.server]
      extract_servers = (config) ->
        if typeof config is 'string'
          [host, port] = config.split ':'
          config = host: host, port: port
        return [] if not config.host or not config.port
        if config.host
          config.host = [config.host] unless Array.isArray config.host
        if config.port
          config.port = [config.port] unless Array.isArray config.port
        servers = []
        for host in config.host or []
          for port in config.port or []
            servers.push host: host, port: port
        servers
      srvs = extract_servers config
      if config.server
        srvs.push ...extract_servers(srv) for srv in config.server
      config.server = srvs
      config.server = utils.array.flatten config.server

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'host':
            $ref: 'module://@nikitajs/network/src/tcp/wait#/definitions/config/properties/host'
            description: '''
            Host of the targeted server, could be a FQDN, a hostname or an IP.
            '''
          'port':
            $ref: 'module://@nikitajs/network/src/tcp/wait#/definitions/config/properties/port'
            description: '''
            Port of the targeted server.
            '''
          'server':
            $ref: 'module://@nikitajs/network/src/tcp/wait#/definitions/config/properties/server'
          'not':
            $ref: 'module://@nikitajs/core/lib/actions/assert#/definitions/config/properties/not'


## Handler

    handler = ({config}) ->
      error = null
      for server in config.server
        try
          await @execute
            command: "bash -c 'echo > /dev/tcp/#{server.host}/#{server.port}'"
          if config.not is true
            error = "Address listening: \"#{server.host}:#{server.port}\""
            break
        catch err
          unless config.not is true
            error = "Address not listening: \"#{server.host}:#{server.port}\""
            break
      throw Error error if error
      true

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: require('./wait').hooks.on_action
      metadata:
        shy: true
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
