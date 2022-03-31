
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.argument', ->
  return unless tags.api
  
  it 'validate schema', ->
    nikita
      $argument_to_config: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/argument_to_config/type'
        'metadata/argument_to_config must be string,'
        'type is "string".'
      ].join ' '
    
  it 'enrich config', ->
    nikita
      $argument_to_config: 'my_key'
    , 'my value', ({config}) ->
      config.should.eql my_key: 'my value'
        
  it 'dont overwrite config', ->
    nikita
      $argument_to_config: 'my_key'
      my_key: 'my original value'
    , 'my new value', ({config}) ->
      config.should.eql my_key: 'my original value'
