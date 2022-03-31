
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.handler.parent', ->
  return unless tags.api
    
  it 'parent config dont conflict', ->
    nikita.call
      parent: true
    , ({config}) ->
      config.parent.should.be.true()
