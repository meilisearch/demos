
###
Plugin `dig`

The plugin export a `dig` function which is used to traverse all the executed
action prior to the current action.

It works similarly to `walk`. However, while `walk` only traverse the parent
hierarchy of actions, `dig` walk the all tree of actions. Like `walk`, it start
with the most recently executed action to the first executed action, the root
action.

###

utils = require '../../utils'

dig_down = (action, digger) ->
  results = []
  for child in action.children.reverse()
    results.push ...(await dig_down child, digger)
  if action.siblings
    for sibling in action.siblings.reverse()
      results.push ...(await dig_down sibling, digger)
  precious = await digger action
  results.push precious unless precious is undefined
  results

dig_up = (action, digger) ->
  results = []
  precious = await digger action
  results.push precious unless precious is undefined
  # TODO, siblings shall never be undefined and always an empty array, isn't ?
  if action.siblings
    for sibling in action.siblings.reverse()
      results.push ...(await dig_down sibling, digger)
  if action.parent
    results.push ...(await dig_up action.parent, digger)
  results

validate = (action, args) ->
  if args.length is 1
    [finder] = args
  else if args.length is 2
    [action, finder] = args
  else throw utils.error 'TOOLS_DIG_INVALID_ARGUMENT', [
    'action signature is expected to be'
    '`finder` or `action, finder`'
    "got #{JSON.stringify args}"
  ] unless action
  throw utils.error 'TOOLS_DIG_ACTION_FINDER_REQUIRED', [
    'argument `action` is missing and must be a valid action'
  ] unless action
  throw utils.error 'TOOLS_DIG_FINDER_REQUIRED', [
    'argument `finder` is missing and must be a function'
  ] unless finder
  throw utils.error 'TOOLS_DIG_FINDER_INVALID', [
    'argument `finder` is missing and must be a function'
  ] unless typeof finder is 'function'
  [action, finder]

module.exports =
  name: '@nikitajs/core/src/plugins/tools/dig'
  hooks:
    'nikita:action': (action) ->
      # Register function
      action.tools ?= {}
      action.tools.dig = ->
        [action, finder] = validate action, arguments
        await dig_up action, finder
