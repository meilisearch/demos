
{tags} = require '../../test'
nikita = require '../../../src'
session = require '../../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.register', ->
  return unless tags.api
  
  it 'alter action - sync', ->
    nikita ({plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            action.config?.key = 'new value'
            handler
      @registry.register ['an', 'action'],
        config: key: 'value'
        handler: (->)
      @an.action ({config}) ->
        config.key.should.eql 'new value'

  it 'alter action - async', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        hooks:
          'nikita:register': ({action}, handler)->
            new Promise (resolve, reject) ->
              setImmediate ->
                action.config?.key = 'new value'
                resolve handler
      context.registry.register ['an', 'action'],
        config: key: 'value'
        handler: (->)
      context.an.action ({config}) ->
        config.key.should.eql 'new value'
          
  it 'handler is undefined', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            (handler is undefined).should.be.ok()
            handler
      context.registry.register ['an', 'action'], {}
