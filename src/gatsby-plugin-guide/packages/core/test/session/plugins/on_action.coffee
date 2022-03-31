
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.plugins.on_action', ->
  return unless tags.api

  it 'call action from global registry', ->
    nikita.call
      $hooks: on_action: ({config}) ->
        config.a_key = 'new value'
      a_key: 'a value'
    , ({config}) ->
      config.a_key.should.eql 'new value'

  it 'error with no handler', ->
    nikita.call
      $hooks: on_action: ({config}) ->
        throw Error 'catchme'
    , ->
      throw Error 'ohno'
    .should.be.rejectedWith 'catchme'

  it 'error before calling handler', ->
    nikita.call
      $hooks: on_action: ({config}, handler) ->
        ->
          throw Error 'catchme'
          await handler.apply null, arguments
      , ->
        throw Error 'ohno'
    .should.be.rejectedWith 'catchme'

  it 'error after calling handler', ->
    nikita.call
      $hooks: on_action: ({config}, handler) ->
        ->
          await handler.apply null, arguments
          throw Error 'catchme'
    , (->)
    .should.be.rejectedWith 'catchme'
        
