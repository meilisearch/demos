
{tags} = require '../../test'
nikita = require '../../../src'
session = require '../../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.result', ->
  return unless tags.api

  it 'is called before action and children resolved', ->
    called = false
    await session $plugins: [
      ->
        hooks: 'nikita:result': ({action}, handler) ->
          await new Promise (resolved) ->
            called = true
            setImmediate resolved
          handler
    ], (->)
    called.should.be.true()
