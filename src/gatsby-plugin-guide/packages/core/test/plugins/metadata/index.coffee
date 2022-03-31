
{tags} = require '../../test'
nikita = require '../../../src'
registry = require '../../../src/registry'
register = require '../../../src/register'

describe 'plugins.metadata.index', ->
  return unless tags.api

  it 'start at 0', ->
    nikita
    .call ({metadata}) ->
      metadata.index.should.eql 0
      @call ({metadata}) ->
        metadata.index.should.eql 0

  it 'is incremented', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.index.should.eql 1
