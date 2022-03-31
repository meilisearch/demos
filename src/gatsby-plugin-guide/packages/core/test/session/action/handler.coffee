
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.action.handler', ->
  return unless tags.api
  
  describe 'root action', ->
    
    it 'return an object', ->
      {key} = await nikita ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'
          
    it 'return an object', ->
      {key} = await nikita ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'namespaced action', ->

    it 'return a promise', ->
      {key} = await nikita().call ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'

    it 'return an object', ->
      {key} = await nikita().call ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'result', ->

    it 'return a user resolved promise', ->
      nikita.call ({config}) ->
        new Promise (accept, reject) ->
          setImmediate -> accept output: 'ok'
      .should.be.finally.containEql output: 'ok', $status: false

    it 'return an action resolved promise', ->
      nikita.call ({config}) ->
        @call ->
          new Promise (accept, reject) ->
            setImmediate -> accept output: 'ok'
      .should.be.finally.containEql output: 'ok', $status: false
