
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.scheduler', ->
  return unless tags.api

  describe 'arguments', ->

    it 'function', ->
      nikita ->
        (await @call ->
          new Promise (resolve) -> resolve 1
        ).should.eql 1

    it 'array', ->
      (await nikita.call [
        -> new Promise (resolve) -> resolve 1
        -> new Promise (resolve) -> resolve 2
      ])
      .should.eql [1, 2]

    it 'array', ->
      (await nikita.call [])
      .should.eql []
