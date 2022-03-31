

module.exports =
  name: '@nikitajs/core/src/plugins/history'
  hooks:
    'nikita:normalize': (action) ->
      action.children = []
      action.siblings ?= []
      action.siblings = action.parent.children if action.parent
      action.sibling = action.siblings.slice(-1)[0] if action.parent
    'nikita:result': ({action, error, output}) ->
      return unless action.parent
      # A bastard is not recognized by their parent as children
      # examples include conditions and assertions
      return if action.metadata.bastard
      action.parent.children.push
        children: action.children
        metadata: action.metadata
        config: action.config
        error: error
        output: output
