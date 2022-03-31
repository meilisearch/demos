
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.argument (native)', ->
  return unless tags.api
  
  describe 'usage', ->

    it 'string', ->
      nikita
      .registry.register ['action'], (->)
      .action 'abc', 'def', ({metadata: {argument}}) ->
        argument.should.eql 'def'

    it 'boolean', ->
      nikita
      .registry.register ['action'], (->)
      .action false, true, ({metadata: {argument}}) ->
        argument.should.eql true

    it 'number', ->
      nikita
      .registry.register ['action'], (->)
      .action 123, 456, ({metadata: {argument}}) ->
        argument.should.eql 456

    it 'null', ->
      nikita
      .registry.register ['action'], (->)
      .action 'abc', null, ({metadata: {argument}}) ->
        should(argument).eql null
