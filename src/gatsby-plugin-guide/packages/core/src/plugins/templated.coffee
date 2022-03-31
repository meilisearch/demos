
selfTemplated = require 'self-templated'

module.exports =
  name: '@nikitajs/core/src/plugins/templated'
  hooks:
    'nikita:action':
      # Note, conditions plugins define templated as a dependency
      before: [
        '@nikitajs/core/src/plugins/metadata/schema'
      ]
      handler: (action) ->
        templated = await action.tools.find (action) -> action.metadata.templated
        return unless templated is true
        selfTemplated action,
          array: true
          compile: false
          mutate: true
          partial:
            assertions: true
            conditions: true
            config: true
            metadata: true
