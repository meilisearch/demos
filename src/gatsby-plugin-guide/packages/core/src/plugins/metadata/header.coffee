

###
The `header` plugin validate the metadata `header` property against the schema.

###

{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/header'
  hooks:
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        header:
          type: 'string'
          description: '''
          Associate a title with the current action.
          '''
