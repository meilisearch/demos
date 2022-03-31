
{tags} = require '../test'
registry = require '../../src/registry'
plugandplay = require 'plug-and-play'

describe 'registry.get', ->
  return unless tags.api
  
  describe 'get all', ->

    it 'get all', ->
      reg = registry.create()
      await reg.register ['get', 'first', 'action'], handler: (->)
      await reg.register ['get', 'second', 'action'], handler: (->)
      reg.get().then (actions) ->
        Object.keys(
          actions.get
        ).should.eql [ 'first', 'second' ]

    it 'with `flatten` config', ->
      reg = registry.create()
      reg.register ['my', 'function'], handler: (->)
      actions = await reg.get flatten: true
      actions.some( (action) -> action.action.join('.') is 'my.function').should.be.true()

    it 'with `flatten` and `deprecate` options', ->
      reg = registry.create()
      reg.register ['new', 'function'], handler: (->)
      reg.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      actions = await reg.get flatten: true, deprecate: false
      actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
      actions.some( (action) -> action.action.join('.') is 'old.function').should.be.false()
      actions = await reg.get flatten: true, deprecate: true
      actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
      actions.some( (action) -> action.action.join('.') is 'old.function').should.be.true()
  
    it 'honors parent actions', ->
      reg_0 = registry.create()
      reg_0.register 'level_0', key: 'level_0', handler: (->)
      reg_1 = registry.create parent: reg_0
      reg_1.register 'level_1', key: 'level_1', handler: (->)
      reg_2 = registry.create parent: reg_1
      reg_2.register 'level_2', key: 'level_2', handler: (->)
      actions = await reg_2.get()
      Object.values(actions)
      .map (action) -> action[''].key
      .should.eql [
        'level_0'
        'level_1'
        'level_2'
      ]
    
    it 'honors parent actions with `flatten` option', ->
      reg_0 = registry.create()
      reg_0.register 'level_0', key: 'level_0', handler: (->)
      reg_1 = registry.create parent: reg_0
      reg_1.register 'level_1', key: 'level_1', handler: (->)
      reg_2 = registry.create parent: reg_1
      reg_2.register 'level_2', key: 'level_2', handler: (->)
      actions = await reg_2.get flatten: true
      actions
      .map (action) -> action.key
      .should.eql [
        'level_0'
        'level_1'
        'level_2'
      ]
  
  describe 'get action', ->

    it 'return null when not registered', ->
      reg = registry.create()
      action = await reg.get ['get', 'an', 'action']
      should(action).be.exactly(null)

    it 'a registered function', ->
      reg = await registry
      .create()
      .register ['get', 'an', 'action'],
        config: key: 'value',
        handler: (->)
      {config} = await reg.get ['get', 'an', 'action']
      config.key.should.eql 'value'

    it 'option `deprecated`', ->
      reg = registry.create()
      reg.register ['new', 'function'], handler: (->)
      reg.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      actions = await reg.get deprecate: false
      actions['new']['function'][''].handler.should.be.type 'function'
      (actions['old'] is undefined).should.be.true()
      actions = await reg.get deprecate: true
      actions['new']['function'][''].handler.should.be.type 'function'
      actions['old']['function'][''].handler.should.be.type 'function'

    it 'return an immutable copy of the action', ->
      reg = registry.create()
      reg.register ['new', 'function'],
        metadata:
          test_1: 'value 1'
        handler: (->)
      # Retrieve the actkon
      action = await reg.get ['new', 'function']
      # Attempt to alter the action
      action.metadata.test_2 = 'value 2'
      # Ensure the attempt failed
      action = await reg.get ['new', 'function']
      action.metadata.should.eql
        test_1: 'value 1'
    
    it 'hook `nikita:registry:normalize` doesnt mutate the action', ->
      reg = registry.create
        plugins: plugandplay
          plugins: [
            ->
              hooks:
                'nikita:registry:normalize': (action) ->
                  action.config?.key = 'new value'
                  action.config?.new_key = 'new value'
          ]
      reg.register ['action'],
        config: key: 'value'
        handler: (->)
      action = await reg.get 'action'
      # Ensure the returned action is altered
      action.should.match
        config:
          key: 'new value', new_key: 'new value'
        handler: (val) -> val.should.be.a.Function()
      # Now, make sure the stored action is not altered
      action = await reg.get 'action', normalize: false
      action.should.match
        config: key: 'value'
        handler: (val) -> val.should.be.a.Function()
