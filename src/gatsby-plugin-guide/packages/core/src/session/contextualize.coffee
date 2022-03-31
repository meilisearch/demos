
{mutate, is_object_literal} = require 'mixme'
utils = require '../utils'

module.exports = (args) ->
  # args_is_array = args.some (arg) -> Array.isArray arg
  # # Multiply the arguments
  # actions = utils.array.multiply ...args
  # Reconstituate the action
  default_action = ->
    config: {}
    metadata: {}
    hooks: {}
    state: {}
  new_action = default_action()
  for arg in args then switch typeof arg
    when 'function'
      if new_action.handler then throw utils.error 'NIKITA_SESSION_INVALID_ARGUMENTS', [
        "handler is already registered, got #{utils.error.got arg}"
      ]
      mutate new_action, handler: arg
    when 'string'
      if new_action.handler then throw utils.error 'NIKITA_SESSION_INVALID_ARGUMENTS', [
        "handler is already registered, got #{JSON.stringigy arg}"
      ]
      mutate new_action, metadata: argument: arg
    when 'object'
      if Array.isArray arg then throw utils.error 'NIKITA_SESSION_INVALID_ARGUMENTS', [
        "argument cannot be an array, got #{utils.error.got arg}"
      ]
      if arg is null
        mutate new_action, metadata: argument: null
      else if is_object_literal arg
        for k, v of arg
          if k is '$'
            # mutate new_action, v
            for kk, vv of v
              if ['config', 'metadata'].includes kk
                new_action[kk] = {...new_action[kk], ...vv}
              else
                new_action[kk] = vv
          else if k[0] is '$'
            if k is '$$'
              mutate new_action.metadata, v
            else
              prop = k.substr 1
              if prop in properties
                new_action[prop] = v
              else
                new_action.metadata[prop] = v
          else
            new_action.config[k] = v unless v is undefined
      else
        mutate new_action, metadata: argument: arg
    else
      mutate new_action, metadata: argument: arg
  # Create empty action when no arguments are provided and not for an empty array
  # new_actions = default_action() if not args.length
  new_action

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'config'
  'parent'
  'plugins'
  'registry'
  'run'
  'scheduler'
  'ssh'
  'state'
]
