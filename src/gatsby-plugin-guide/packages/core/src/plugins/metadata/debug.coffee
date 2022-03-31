
utils = require '../../utils'
stream = require 'stream'
{mutate} = require 'mixme'

###
Print log information to the console.

Only the logs which type match "text", "stdin", "stdout_stream", "stderr_stream" are handled.

TODO: detect/force isTTY
###

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/debug'
  require: '@nikitajs/core/src/plugins/tools_log'
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        debug:
          oneOf: [
            type: 'boolean'
          ,
            type: 'string'
            enum: ['stdout', 'stderr']
          ,
            instanceof: 'stream.Writable'
          ]
          description: '''
          Print detailed information of an action and its children. It provides
          a quick and convenient solution to understand the various actions
          called, what they do, and in which order.
          '''
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/metadata/schema'
      ]
      handler: (action) ->
        return unless action.metadata.debug
        debug = action.metadata.debug
        debug = action.metadata.debug =
          ws:
            if debug is 'stdout'
              action.metadata.debug.ws = process.stdout
            else if debug is 'stderr'
              action.metadata.debug.ws = process.stderr
            else if debug instanceof stream.Writable
              action.metadata.debug.ws = debug
            else
              action.metadata.debug.ws = process.stderr
          listener: (log) ->
            unless log.type in ['stdout_stream', 'stderr_stream'] and log.message is null
              msg = if typeof log.message is 'string' then log.message.trim()
              else if typeof log.message is 'number' then log.message
              else if log.message?.toString? then log.message.toString().trim()
              else JSON.stringify log.message
              position = log.position.map((i) -> i+1).join '.'
              namespace = log.namespace.join '.' if log.namespace
              name = namespace or log.module
              msg = [
                '['
                position+'.'+log.level
                ' '+name if name
                '] '
                msg
              ].join ''
              msg = switch log.type
                when 'stdin' then "\x1b[33m#{msg}\x1b[39m"
                when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
                when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
                else "\x1b[32m#{msg}\x1b[39m"
              debug.ws.write "#{msg}\n"
        action.tools.events.addListener 'text', debug.listener
        action.tools.events.addListener 'stdin', debug.listener
        action.tools.events.addListener 'stdout_stream', debug.listener
        action.tools.events.addListener 'stderr_stream', debug.listener
    'nikita:result':
      handler: ({action}) ->
        debug = action.metadata.debug
        return unless debug and debug.listener
        action.tools.events.removeListener 'text', debug.listener
        action.tools.events.removeListener 'stdin', debug.listener
        action.tools.events.removeListener 'stdout_stream', debug.listener
        action.tools.events.removeListener 'stderr_stream', debug.listener
