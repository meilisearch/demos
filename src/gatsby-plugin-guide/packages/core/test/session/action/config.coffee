
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.handler.config', ->
  return unless tags.api
    
  it 'ensure it is not polluted', ->
    nikita.call ({config}) ->
      config.should.eql {}
