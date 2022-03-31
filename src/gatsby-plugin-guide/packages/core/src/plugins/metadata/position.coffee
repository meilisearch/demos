
{mutate} = require 'mixme'
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/position'
  require: [
    '@nikitajs/core/src/plugins/history'
  ]
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        depth:
          type: 'integer'
          description: '''
          Indicates the level number of the action in the Nikita session tree.
          '''
          default: 0
          readOnly: true
        index:
          type: 'integer'
          description: '''
          Indicates the index of an action relative to its sibling actions in
          the Nikita session tree.
          '''
          default: 0
          readOnly: true
        position:
          type: 'array'
          items: type: 'integer'
          description: '''
          Indicates the position of the action relative to its parent and
          sibling action. It is unique to each action.
          '''
          default: [0]
          readOnly: true
    'nikita:normalize':
      after: '@nikitajs/core/src/plugins/history'
      handler: (action) ->
        action.metadata.depth = if action.parent then action.parent.metadata.depth + 1 else 0
        # plugins are not activated in the root session with {depth: 0}
        action.metadata.index = if action.siblings then action.siblings.length else 0
        action.metadata.position = if action.parent then action.parent.metadata.position.concat [action.metadata.index] else [0]
    'nikita:action': (action) ->
      unless typeof action.metadata.depth is 'number'
        throw utils.error 'METADATA_DEPTH_INVALID_VALUE', [
          "configuration `depth` expect an integer value,"
          "got #{JSON.stringify action.metadata.depth}."
        ]
