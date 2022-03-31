

###
The `args` plugin place the original argument into the action "args" property.

###
utils = require '../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/args'
  hooks:
    'nikita:arguments':
      handler: ({args, child}, handler) ->
        # return handler is args.length is 0 # nikita is called without any args, eg `nikita.call(...)`
        # Erase all arguments to re-inject them later
        # return null if args.length is 1 and args[0]?.args
        if child?.metadata?.raw_input #or child?.metadata?.raw
          arguments[0].args = [{}]
        ->
          action = handler.apply null, arguments
          # If raw_input is activated, just pass arguments as is
          # Always one action since arguments are erased
          if child?.metadata?.raw_input
            action.args = args
            action.metadata.raw_input = true
          action.args = args
          action
    'nikita:normalize': (action, handler) ->
      ->
        # Prevent arguments to move into config by normalize
        args = action.args
        delete action.args
        action = await handler.apply null, arguments
        action.args = args
        action
