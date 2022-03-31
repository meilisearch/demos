
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.disabled', ->
  return unless tags.api
  
  it 'validate schema', ->
    nikita
      $disabled: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/disabled/type'
        'metadata/disabled must be boolean, type is "boolean".'
      ].join ' '
  
  it 'default', ->
    nikita.call
      $disabled: false
    , ({metadata: {disabled}}) ->
      disabled.should.be.false()

  it 'when `true`', ->
    nikita.call
      $disabled: true
      $handler: -> throw Error 'forbidden'

  it 'when `false`', ->
    nikita.call
      $disabled: false
      $handler: -> 'called'
    .should.be.resolvedWith 'called'
