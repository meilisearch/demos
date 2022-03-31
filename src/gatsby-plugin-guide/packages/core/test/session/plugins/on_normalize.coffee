
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.plugins.on_normalize', ->
  return unless tags.api

  it 'call action from global registry', ->
    nikita.call
      $hooks: on_normalize: ({config}, handler) ->
        ->
          action = handler.call null, ...arguments
          action.config.a_key = 'new value'
          action
      a_key: 'a value'
    , ({config}) ->
      config.a_key.should.eql 'new value'

  it 'catch errors', ->
    nikita.call
      $hooks: on_normalize: ({config}, handler) ->
        throw Error 'catchme'
    .should.be.rejectedWith 'catchme'

  it 'errors in parent are cascaded to children', ->
    # Error is throw at level 0
    nikita
      $hooks: on_normalize:
        handler: ({metadata}, handler) ->
          # Plugins tools.events was complaining that tools did not exists (for
          # some weird reasons, only when executing all the tests`), by throwing
          # the error after the executed handler, we ensure most the normalize
          # events are already executed
          ->
            handler.apply null, arguments
            throw Error 'catchme'
    # But we want it to be returned by level 1
    .call (-> console.log 'oh no')
    .should.be.rejectedWith 'catchme'
        
