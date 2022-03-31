
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/relax'
  hooks:
    'nikita:action': (action, handler) ->
      action.metadata.relax ?= false
      if typeof action.metadata.relax is 'string' or
      action.metadata.relax instanceof RegExp
        action.metadata.relax = [action.metadata.relax]
      unless typeof action.metadata.relax is 'boolean' or
      action.metadata.relax instanceof Array
        throw utils.error 'METADATA_RELAX_INVALID_VALUE', [
          "configuration `relax` expects a boolean, string, array or regexp",
          "value, got #{JSON.stringify action.metadata.relax}."
        ]
      return handler
    'nikita:result': (args) ->
      return unless args.action.metadata.relax
      return unless args.error
      return if args.error.code is 'METADATA_RELAX_INVALID_VALUE'
      if args.action.metadata.relax is true or
      args.action.metadata.relax.includes(args.error.code) or
      args.action.metadata.relax.some((v) -> args.error.code.match v)
        args.output ?= {}
        args.output.error = args.error
        args.error = undefined
