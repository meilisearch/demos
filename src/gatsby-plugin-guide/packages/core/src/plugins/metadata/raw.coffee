
{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/raw'
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        raw:
          type: 'boolean'
          description: '''
          Indicates the level number of the action in the Nikita session tree.
          '''
          default: false
          readOnly: true
        raw_input:
          type: 'boolean'
          description: '''
          Indicates the index of an action relative to its sibling actions in
          the Nikita session tree.
          '''
          readOnly: true
        raw_output:
          type: 'boolean'
          description: '''
          Indicates the position of the action relative to its parent and
          sibling action. It is unique to each action.
          '''
          readOnly: true
    'nikita:registry:normalize':
      handler: (action) ->
        action.metadata ?= {}
        wasDefinedAndValid = action.metadata.raw isnt undefined and typeof action.metadata.raw is 'boolean'
        action.metadata.raw ?= false
        action.metadata.raw_input ?= action.metadata.raw if wasDefinedAndValid
        action.metadata.raw_output ?= action.metadata.raw if wasDefinedAndValid
    'nikita:action':
      # before: '@nikitajs/core/src/plugins/metadata/schema'
      handler: (action) ->
        wasDefinedAndValid = action.metadata.raw isnt undefined and typeof action.metadata.raw is 'boolean'
        action.metadata.raw ?= false
        action.metadata.raw_input ?= action.metadata.raw if wasDefinedAndValid
        action.metadata.raw_output ?= action.metadata.raw if wasDefinedAndValid
