
###
Traverse the parent hierarchy until it find a value. The traversal will only
stop if the user function return anything else than `undefined`, including
`null` or `false`.
###

utils = require '../../utils'

find = (action, finder) ->
  precious = await finder action, finder
  return precious unless precious is undefined
  return undefined unless action.parent
  find action.parent, finder

validate = (action, args) ->
  if args.length is 1
    [finder] = args
  else if args.length is 2
    [action, finder] = args
  else throw utils.error 'TOOLS_FIND_INVALID_ARGUMENT', [
    'action signature is expected to be'
    '`finder` or `action, finder`'
    "got #{JSON.stringify args}"
  ] unless action
  throw utils.error 'TOOLS_FIND_ACTION_FINDER_REQUIRED', [
    'argument `action` is missing and must be a valid action'
  ] unless action
  throw utils.error 'TOOLS_FIND_FINDER_REQUIRED', [
    'argument `finder` is missing and must be a function'
  ] unless finder
  throw utils.error 'TOOLS_FIND_FINDER_INVALID', [
    'argument `finder` is missing and must be a function'
  ] unless typeof finder is 'function'
  [action, finder]

module.exports =
  name: '@nikitajs/core/src/plugins/tools/find'
  hooks:
    'nikita:normalize': (action, handler) ->
      ->
        # Handler execution
        action = await handler.apply null, arguments
        # Register function
        action.tools ?= {}
        action.tools.find = ->
          [action, finder] = validate action, arguments
          await find action, finder
        # Register action
        action.registry.register ['tools', 'find'],
          metadata: raw: true
          handler: (action) ->
            [action, finder] = validate action, action.args
            await find action.parent, finder
        action
