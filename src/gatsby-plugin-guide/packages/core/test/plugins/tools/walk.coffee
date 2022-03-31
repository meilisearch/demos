
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.walk', ->
  return unless tags.api
  
  describe 'action', ->

    it 'start in current action', ->
      nikita.call a_key: 'a value', ->
        @tools.walk (action) ->
          action.config.a_key
        .should.be.resolvedWith ['a value']

    it 'start traverse the parent hierarchy', ->
      nikita.call a_key: '1', ->
        @call a_key: '2', ->
          @call a_key: '3', ->
            @tools.walk ({config}) ->
              config.a_key
            .should.be.resolvedWith ['3', '2', '1']

    it 'starting from parent action', ->
      nikita.call a_key: '1', ->
        @call -> @call -> @call -> @call a_key: '2', (action) ->
          @tools.walk action.parent.parent, ({config}) ->
            config.a_key
          .should.be.resolvedWith ['1']

    it 'skip undefined returned value', ->
      nikita.call a_key: '1', ->
        @call -> @call -> @call -> @call a_key: '2', ->
          @tools.walk ({config}) ->
            config.a_key
          .should.be.resolvedWith ['2', '1']
            
  describe 'function', ->

    it 'start in current action', ->
      nikita.call a_key: '1', ({tools}) ->
        tools.walk ({config}) ->
          config.a_key
        .should.be.resolvedWith ['1']
    
    
