
{v4: uuid} = require 'uuid'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/uuid'
  hooks:
    'nikita:action':
      handler: (action) ->
        if action.metadata.depth is 0
          action.metadata.uuid = uuid()
        else
          action.metadata.uuid = action.parent.metadata.uuid
