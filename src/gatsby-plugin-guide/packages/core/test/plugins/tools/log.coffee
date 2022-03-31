
{tags} = require '../../test'
nikita = require '../../../src'
stream = require 'stream'

describe 'plugins.tools.log', ->
  return unless tags.api

  describe 'events', ->
    
    it 'are emitted', ->
      nikita ({tools: {events, log}}) ->
        new Promise (resolve) ->
          events.on 'text', (msg) ->
            resolve msg
          log message: 'getme'
        .should.finally.containEql
          message: 'getme'
          level: 'INFO'
          index: 0
          module: undefined
          namespace: []
          type: 'text'
          depth: 0
          file: 'log.coffee'
          filename: __filename
          line: 23
          
    it 'argument is immutable', ->
      arg = key: 'value'
      await nikita.call ({tools: {log}}) ->
        log arg
        true
      arg.should.eql key: 'value'
  
  describe 'is a `boolean`', ->
      
    it 'equals `true`', ->
      data = []
      await nikita
      .call ({tools: {events}}) ->
        events.on 'text', (log) -> data.push log.message
      .call $log: true, ({tools: {log}}) ->
        log message: 'enabled parent'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql ['enabled parent', 'enabled child']
    
    it 'equals `false`', ->
      data = []
      await nikita
      .call ({tools: {events}}) ->
        events.on 'text', (log) -> data.push log.message
      .call $log: false, ({tools: {log}}) ->
        log message: 'disabled'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql []
  
  describe 'is a `function`', ->
  
    it 'argument `log`', ->
      data = []
      await nikita
      .call
        $log: ({log}) ->
          data.push log.message
      , ({tools: {log}}) ->
        log message: 'enabled parent'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql ['enabled parent', 'enabled child']
      
    it 'arguments', ->
      data = null
      await nikita
      .call
        $log: (args) ->
          data = Object.keys(args).sort()
      , ({tools: {log}}) ->
        log message: 'enabled parent'
      data.should.eql ['config', 'log', 'metadata']
