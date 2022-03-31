
{tags} = require '../test'
contextualize = require '../../src/session/contextualize'
normalize = require '../../src/session/normalize'

describe 'session.normalize', ->
  return unless tags.api
  
  it 'handle function as handler', ->
    expect =
      handler: (->)
      config: a: ''
      hooks: {}
      metadata: {}
      state: {}
    # String is place before objects
    normalize contextualize [
      (->)
      {a: ''}
    ]
    # Filter only metadata.argument and config
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      {a: ''}
      (->)
    ]
    # Filter only metadata.argument and config
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect =
      metadata: argument: 'a'
      config: b: ''
      hooks: {}
      state: {}
    # String is place before objects
    normalize contextualize [
      'a'
      {b: ''}
    ]
    # Filter only metadata.argument and config
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      {b: ''}
      'a'
    ]
    # Filter only metadata.argument and config
    .should.eql expect
