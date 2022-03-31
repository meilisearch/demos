
{tags} = require '../test'
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.registered', ->
  return unless tags.api

  describe 'global', ->

    it 'return false with 1 level', ->
      registry.registered('does_not_exists').should.be.false()
      registry.registered(['does_not_exists']).should.be.false()

    it 'return false with multi level', ->
      registry.registered(['does', 'not', 'exists']).should.be.false()

    it 'return true with 1 level', ->
      await registry.register ['my_module'], (->)
      registry.registered('my_module').should.be.true()
      registry.registered(['my_module']).should.be.true()
      registry.unregister ['my_module']

    it 'return true with multi level', ->
      await registry.register ['my', 'module'], (->)
      registry.registered(['my', 'module']).should.be.true()
      registry.registered(['my']).should.be.false()
      registry.unregister ['my', 'module']

  describe 'local', ->

    it 'return false with 1 level', ->
      nikita
      .registry.registered 'does_not_exists'
      .should.be.finally.false()
      nikita
      .registry.registered ['does_not_exists']
      .should.be.finally.false()

    it 'return false with multi level ', ->
      nikita
      .registry.registered ['does', 'not', 'exists']
      .should.be.finally.false()

    it 'return true with 1 level', ->
      n = nikita.registry.register ['my_action'], handler: (->)
      result = await n.registry.registered('my_action')
      result.should.be.true()
      result = await n.registry.registered(['my_action'])
      result.should.be.true()

    it 'return true with multi level', ->
      n = nikita.registry.register ['my', 'module'], handler: (->)
      result = await n.registry.registered(['my', 'module'])
      result.should.be.true()
      result = await n.registry.registered(['my'])
      result.should.be.false()

  describe 'parent', ->

    it 'accept property declared in parent', ->
      reg_0 = registry.create()
      reg_0.register 'parent_0_action', (->)
      reg_1 = registry.create parent: reg_0
      reg_1.register 'parent_1_action', (->)
      reg_2 = registry.create parent: reg_1
      reg_2.register 'parent_2_action', (->)
      reg_2.registered('parent_2_action').should.be.true()
      reg_2.registered('parent_1_action').should.be.true()
      reg_2.registered('parent_0_action').should.be.true()
  
  describe 'partial', ->

    it 'check action', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['my', 'nice', 'module'], partial: true).should.be.true()

    it 'check namespace', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['my'], partial: true).should.be.true()
      reg.registered(['my', 'nice'], partial: true).should.be.true()

    it 'ensure non enumerable property are skipped', ->
      reg = registry.create()
      reg.registered(['register'], partial: true).should.be.false()

    it 'option partial check all path', ->
      reg = registry.create()
      reg.register ['my', 'nice', 'module'], (->)
      reg.registered(['wrong', 'nice'], partial: true).should.be.false()

    it 'honor parent', ->
      reg_parent = registry.create()
      reg_parent.register ['my', 'nice', 'module'], (->)
      reg_child = registry.create parent: reg_parent
      reg_child.registered(['my', 'nice'], partial: true).should.be.true()
