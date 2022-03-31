
{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/disabled'
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        disabled:
          type: 'boolean'
          description: '''
          Disable the execution of the current action  and consequently the
          execution of its child actions.
          '''
          default: false
    'nikita:action': (action, handler) ->
      # Note, we dont enforce schema validation before it because
      # When a plugin a disabled, chances are that not all its property
      # where passed correctly and we don't want schema validation
      # to throw an error in such cases
      action.metadata.disabled ?= false
      if action.metadata.disabled is true then null else handler
