
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.status', ->
  return unless tags.api

  it 'root', ->
    nikita ({tools: {status}}) ->
      status().should.be.false()

  it 'root with executed siblings', ->
    nikita ({tools: {status}}) ->
      await @call -> false
      await @call -> true
      await @call -> false
      status().should.be.true()

  it 'index', ->
    nikita ({tools: {status}}) ->
      await @call -> true
      await @call -> false
      status(0).should.be.true()
      status(1).should.be.false()

  it 'reverse index', ->
    nikita ({tools: {status}}) ->
      await @call -> true
      await @call -> false
      status(-2).should.be.true()
      status(-1).should.be.false()
