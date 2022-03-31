
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.raw_output', ->
  return unless tags.api
  
  it 'validate schema', ->
    nikita
      $raw_output: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/raw_output/type'
        'metadata/raw_output must be boolean,'
        'type is "boolean".'
      ].join ' '
    
  it 'get default from `raw`', ->
    await nikita
      $raw: true
    , ({metadata}) ->
      metadata.raw_output.should.be.true()
    await nikita
      $raw: false
    , ({metadata}) ->
      metadata.raw_output.should.be.false()
    await nikita
      $raw: undefined
    , ({metadata}) ->
      metadata.raw_output.should.be.false()

  it 'leave `true` as is', ->
    nikita.call $raw_output: true, -> true
    .should.be.resolvedWith true
      
  it 'leave `false` as is', ->
    nikita.call $raw_output: true, -> true
    .should.be.resolvedWith true

  it 'leave `{}` as is', ->
    nikita.call $raw_output: true,-> {}
    .should.be.resolvedWith {}
    
    
