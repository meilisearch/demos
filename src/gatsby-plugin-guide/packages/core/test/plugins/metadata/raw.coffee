
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.raw', ->
  return unless tags.api
  
  it 'validate schema', ->
    nikita
      $raw: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/raw/type'
        'metadata/raw must be boolean,'
        'type is "boolean".'
      ].join ' '
    
  it 'get default from `raw`', ->
    await nikita
      $raw: true
    , ({metadata}) ->
      metadata.raw.should.be.true()
    await nikita
      $raw: false
    , ({metadata}) ->
      metadata.raw.should.be.false()
    await nikita
      $raw: undefined
    , ({metadata}) ->
      metadata.raw.should.be.false()
