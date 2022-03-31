

###
The `magic_dollar` plugin extract all variables starting with a dollar sign.
###

{is_object_literal} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/magic_dollar'
  hooks:
    'nikita:normalize':
      handler: (action) ->
        for k, v of action
          continue unless k[0] is '$'
          prop = k.substr 1
          switch prop
            when 'handler'
              action.handler = v
            when 'parent'
              action.parent = v
            when 'scheduler'
              action.scheduler = v
            else
              action.metadata[prop] = v
          delete action[k]
        
