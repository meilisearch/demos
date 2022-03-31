

###
The `argument` plugin map an argument which is not an object into a configuration property.

###

{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/argument_to_config'
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        argument_to_config:
          type: 'string'
          description: '''
          Maps the argument passed to the action to a configuration property.
          '''
    'nikita:action':
      before: [
        '@nikitajs/core/src/plugins/metadata/schema'
      ]
      handler: (action) ->
        if action.metadata.argument_to_config
          action.config[action.metadata.argument_to_config] ?= action.metadata.argument
