
{is_object, is_object_literal} = require 'mixme'
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/output/status'
  require: [
    '@nikitajs/core/src/plugins/history'
    '@nikitajs/core/src/plugins/metadata/raw'
  ]
  recommand: [
    # status is set to `false` when action is disabled
    '@nikitajs/core/src/plugins/metadata/disabled'
  ]
  hooks:
    # 'nikita:registry:normalize': (action) ->
    #   action.metadata ?= {}
    #   action.metadata.shy ?= false
    'nikita:normalize': (action) ->
      action.tools ?= {}
      action.tools.status = (index) ->
        if arguments.length is 0
          action.children.some (sibling) ->
            not sibling.metadata.shy and sibling.output?.$status is true
        else
          l = action.children.length
          i =  if index < 0 then (l + index) else index
          sibling = action.children[i]
          throw Error "Invalid Index #{index}" unless sibling
          sibling.output.$status
    'nikita:result':
      before: '@nikitajs/core/src/plugins/history'
      handler: ({action, error, output}) ->
        # Honors the disabled plugin, status is `false`
        # when the action is disabled
        if action.metadata.disabled
          arguments[0].output = $status: false 
          return
        inherit = (output) ->
          output ?= {}
          output.$status = action.children.some (child) ->
            return false if child.metadata.shy
            child.output?.$status is true
          output
        if not error and not action.metadata.raw_output
          arguments[0].output =
            if typeof output is 'boolean'
              $status: output
            else if is_object_literal output
              if output.hasOwnProperty '$status'
                output.$status = !!output.$status
                output
              else
                inherit output
            else if output is null
              output
            else if not output?
              inherit output
            else if is_object output
              output
            else if Array.isArray(output) or typeof output in ['string', 'number']
              output
            else
              throw utils.error 'HANDLER_INVALID_OUTPUT', [
                'expect a boolean or an object or nothing'
                'unless the `raw_output` configuration is activated,'
                "got #{JSON.stringify output}"
              ]
      
            
