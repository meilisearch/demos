
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.find', ->
  return unless tags.api
  
  describe 'action', ->

    it 'start in current action', ->
      nikita.call a_key: 'a value', ->
        @tools.find (action) ->
          action.config.a_key
        .should.be.resolvedWith 'a value'

    it 'traverse the parent hierarchy', ->
      nikita.call a_key: 'a value', ->
        @call ->
          count = 0
          @tools.find (action) ->
            count++
            return unless action.config.a_key
            a_key: action.config.a_key, depth: action.metadata.depth
          .should.be.resolvedWith a_key: 'a value', depth: 1
          .then -> count.should.eql 2

    it 'traverse from parent', ->
      nikita.call a_key: 'a value', ->
        @call -> @call -> @call -> @call (action) ->
          count = 0
          @tools.find action.parent.parent, (action) ->
            count++
            return unless action.config.a_key
            a_key: action.config.a_key, depth: action.metadata.depth
          .should.be.resolvedWith a_key: 'a value', depth: 1
          .then -> count.should.eql 2
    
  describe 'function', ->

    it 'start in current action', ->
      nikita.call a_key: 'a value', ({tools}) ->
        tools.find (action) ->
          action.config.a_key
        .should.be.resolvedWith 'a value'
          
  describe 'usage', ->
    
    it 'return the first value found', ->
      nikita
      .call key: '1', stop: true, ->
        @call key: '1.1', stop: true, ->
          @call key: '1.1.1', ({tools: {find}}) ->
            find ({config}) ->
              config.key if config.stop
            .should.be.resolvedWith '1.1'
    
    it 'null is interpreted as a value', ->
      nikita
      .call key: '1', stop: true, ->
        @call key: null, stop: true, ->
          @call key: '1.1.1', ({tools: {find}}) ->
            find ({config}) ->
              config.key if config.stop
            .should.be.resolvedWith null
      
    
    
