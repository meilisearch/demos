
{tags} = require '../test'
nikita = require '../../src'
session = require '../../src/session'

describe 'session.creation', ->
  return unless tags.api
  
  describe 'args is array of actions', ->

    it 'first throw error', ->
      (->
        session []
      ).should.throw
        code: 'NIKITA_SESSION_INVALID_ARGUMENTS'
        message: [
          'NIKITA_SESSION_INVALID_ARGUMENTS:'
          'argument cannot be an array, got []'
        ].join ' '
  
    it 'which succeed', ->
      (->
        session [
          -> new Promise (resolve) ->
            setTimeout ->
              resolve 1
            , 100
          -> new Promise (resolve) ->
            setTimeout ->
              resolve 2
            , 10
        ]
      ).should.throw
        code: 'NIKITA_SESSION_INVALID_ARGUMENTS'
        message: [
          'NIKITA_SESSION_INVALID_ARGUMENTS:'
          'argument cannot be an array, got [function,function]'
        ].join ' '
        
  describe 'flow with external action', ->
    
    it 'plugin and handler and no external action', ->
      # No external action but we use it as a reference
      stack = []
      await nikita
        $hooks: on_action: (action)->
          new Promise (resolve) ->
            setTimeout ->
              stack.push 'plugin'
              resolve()
            , 100
      , ->
        @call ({metadata}) ->
          stack.push metadata.position.join ':'
        @call ({metadata}) ->
          stack.push metadata.position.join ':'
      stack.should.eql ['plugin', '0:0', '0:1']
          
    it 'after no plugin and no handler but a property object', ->
      stack = []
      await nikita
        key: 'value'
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      stack.should.eql ['0:0', '0:1']
    
    it 'after plugin', ->
      stack = []
      await nikita
        $hooks: on_action: (action)->
          new Promise (resolve) ->
            setTimeout ->
              stack.push 'plugin'
              resolve()
            , 100
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      stack.should.eql ['plugin', '0:0', '0:1']
  
    it 'after plugin and handler', ->
      stack = []
      await nikita
        $hooks: on_action: (action) ->
          new Promise (resolve) ->
            setTimeout ->
              stack.push 'plugin'
              resolve()
            , 100
      , ({metadata}) ->
        @call ({metadata}) ->
          new Promise (resolve) ->
            setTimeout ->
              stack.push metadata.position.join ':'
              resolve()
            , 100
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      .call ({metadata}) ->
        stack.push metadata.position.join ':'
      stack.should.eql ['plugin', '0:0', '0:1', '0:2']
    
