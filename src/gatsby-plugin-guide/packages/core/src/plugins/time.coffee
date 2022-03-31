
module.exports =
  name: '@nikitajs/core/src/plugins/time'
  hooks:
    'nikita:action':
      handler: (action) ->
        action.metadata.time_start = Date.now()
    'nikita:result':
      before: '@nikitajs/core/src/plugins/history'
      handler: ({action}) ->
        action.metadata.time_end = Date.now()
