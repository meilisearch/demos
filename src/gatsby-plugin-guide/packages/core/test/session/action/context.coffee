
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.handler.context', ->
  return unless tags.api
  
  it 'context config dont conflict', ->
    nikita.call
      context: true
    , ({config}) ->
      config.context.should.be.true()
