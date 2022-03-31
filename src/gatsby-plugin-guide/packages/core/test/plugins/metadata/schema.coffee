
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.schema', ->
  return unless tags.api

  it 'disabled when `false`', ->
    nikita
    .registry.register ['test', 'schema'],
      metadata: definitions: config:
        type: 'object'
        properties:
          'a_key': type: 'string'
        required: ['a_key']
      handler: (->)
    .test.schema
      $schema: false
      $handler: (->)
