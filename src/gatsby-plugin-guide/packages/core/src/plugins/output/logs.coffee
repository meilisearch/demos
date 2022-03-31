

###
Return events emitted inside the action

###

{is_object_literal} = require 'mixme'
stackTrace = require 'stack-trace'
path = require 'path'

module.exports =
  name: '@nikitajs/core/src/plugins/output/logs'
  require: [
    '@nikitajs/core/src/plugins/tools_log'
    '@nikitajs/core/src/plugins/output/status'
    '@nikitajs/core/src/plugins/metadata/raw'
  ]
  hooks:
    'nikita:action':
      after: '@nikitajs/core/src/plugins/tools_log'
      handler: (action) ->
        action.state.logs = []
        action.tools.log = ( (fn) ->
          (info) ->
            log = fn.call null, info
            # Note, log is undefined if `metadata.log` is `false`
            # or any value return by `metadata.log` when a function
            return log unless is_object_literal log
            # Re-compute filename
            frame = stackTrace.get()[1]
            log.filename = frame.getFileName()
            log.file = path.basename(frame.getFileName())
            log.line = frame.getLineNumber()
            # Push log to internal state
            action.state.logs.push log
            log
        )(action.tools.log)
    'nikita:result':
      after: '@nikitajs/core/src/plugins/output/status'
      handler: ({action, output}, handler) ->
        return handler if action.metadata.raw_output
        ({action}) ->
          try
            output = await handler.apply null, arguments
            output.$logs = action.state.logs if is_object_literal output
            output
          catch err
            err.$logs = action.state.logs
            throw err
