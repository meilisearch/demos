###
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
###

utils = require '../../utils'
{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/schema'
  require: [
    '@nikitajs/core/src/plugins/tools/schema'
  ]
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        definitions:
          type: 'object'
          description: '''
          Schema definition or `false` to disable schema validation in the
          current action.
          '''
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/global'
        '@nikitajs/core/src/plugins/metadata/disabled'
      ]
      handler: (action) ->
        return if action.metadata.schema is false
        err = await action.tools.schema.validate action
        throw err if err
  
