
{tags} = require '../test'
nikita = require '../../src'
registry = require '../../src/registry'

# Test the construction of the session namespace stored in state

describe 'session.namespace', ->
  return unless tags.api

  it 'call registered action', ->
    nikita ({registry}) ->
      registry.register
        'action':
          '': handler: ({metadata}) ->
            @an.action()
            "action value, depth #{metadata.depth}"
        'an':
          'action':
            '': handler: ({metadata}) ->
              "an.action value, depth #{metadata.depth}"
      result = await @action()
      result.should.eql 'action value, depth 1'
      result = await @an.action()
      result.should.eql 'an.action value, depth 1'

  it 'chain calls', ->
    n = nikita ({registry}) ->
      registry.register
        'action':
          '': handler: ({metadata}) ->
            @an.action()
            "action value, depth #{metadata.depth}"
        'an':
          'action':
            '': handler: ({metadata}) ->
              "an.action value, depth #{metadata.depth}"
      result = await @action().action()
      result.should.eql 'action value, depth 1'
      result = await @an.action().an.action()
      result.should.eql 'an.action value, depth 1'
  
  describe 'error unregistered namespace', ->

    it 'unregisted root action from static', ->
      nikita.invalid()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["invalid"].'
      ].join ' '

    it 'unregisted root action from instance', ->
      nikita().invalid()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["invalid"].'
      ].join ' '

    it 'chain action after unregisted action', ->
      nikita().invalid.action()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["invalid","action"].'
      ].join ' '

    it 'unregisted action within a registered namespace outside handler', ->
      nikita ({registry}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
      .an.action.broken()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["an","action","broken"].'
      ].join ' '

    it 'unregisted action within a registered namespace inside handler', ->
      nikita ({registry, context}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
        context.an.action.broken()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["an","action","broken"].'
      ].join ' '

    it 'unregisted action within a registered static namespace', ->
      # Internally, the proxy for nikita is not the same as for its children
      registry.register ['an', 'action'], (->)
      nikita.an.action.invalid()
      .should.be.rejectedWith [
        'ACTION_UNREGISTERED_NAMESPACE:'
        'no action is registered under this namespace,'
        'got ["an","action","invalid"].'
      ].join ' '
      registry.unregister ['an', 'action']
