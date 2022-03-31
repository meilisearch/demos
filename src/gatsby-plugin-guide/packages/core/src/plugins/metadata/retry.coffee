
{merge} = require 'mixme'
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/retry'
  hooks:
    'nikita:action': (action, handler) ->
      action.metadata.attempt ?= 0
      action.metadata.retry ?= 1
      action.metadata.sleep ?= 3000
      for property in ['attempt', 'sleep', 'retry']
        if typeof action.metadata[property] is 'number'
          if action.metadata[property] < 0
            throw utils.error "METADATA_#{property.toUpperCase()}_INVALID_RANGE", [
              "configuration `#{property}` expect a number above or equal to 0,"
              "got #{action.metadata[property]}."
            ]
        else unless typeof action.metadata[property] is 'boolean'
          throw utils.error "METADATA_#{property.toUpperCase()}_INVALID_VALUE", [
            "configuration `#{property}` expect a number or a boolean value,"
            "got #{JSON.stringify action.metadata[property]}."
          ]
      (args) ->
        action = args
        {retry} = action.metadata
        config = merge {}, action.config
        # Handle error
        failure = (err) ->
          throw err if retry isnt true and action.metadata.attempt >= retry - 1
          # Increment the attempt metadata
          action.metadata.attempt++
          action.config = merge {}, config
          # Reschedule
          run()
        run = ->
          try
            await handler.call null, args
          catch err then failure err
        run()
