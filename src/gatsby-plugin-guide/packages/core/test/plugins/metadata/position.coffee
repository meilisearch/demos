
{tags} = require '../../test'
nikita = require '../../../src'
registry = require '../../../src/registry'
register = require '../../../src/register'

describe 'plugins.metadata.position', ->
  return unless tags.api

  it 'start at 0', ->
    nikita ({metadata}) ->
      metadata.position.should.eql [0]

  it 'are concatenated', ->
    nikita
    .call ({metadata}) ->
      metadata.position.should.eql [0, 0]

  it 'are incremented', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.position.should.eql [0, 1]
      @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
      @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 1]

  it 'honors `metadata.bastard`', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.position.should.eql [0, 1]
      @call $bastard: true, ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
      @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
