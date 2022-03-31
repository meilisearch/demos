
{tags} = require '../test'
nikita = require '../../src'
session = require '../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.error', ->
  return unless tags.api
  
  describe 'cascade', ->
  
    it 'error in last action but return valid result', ->
      session ->
        @call (->)
        @call ->
          throw Error 'KO'
        'OK'
      .should.be.resolvedWith 'OK'
      
    it 'thrown error sync in last action', ->
      session ->
        @call (->)
        @call ->
          throw Error 'OK'
      .should.be.rejectedWith 'OK'
      
    it 'thrown error sync in first action', ->
      session name: 'parent', ->
        # Note, it is mandatory to wait for the promise completion
        # since we cant stop the execution flow if an action failed.
        await @call ->
          throw Error 'OK'
        @call ->
          throw Error 'KO'
      .should.be.rejectedWith 'OK'
        
    it 'thrown error async in last action', ->
      session ->
        @call (->)
        @call ->
          new Promise (resolve, reject) ->
            setImmediate -> reject Error 'OK'
      .should.be.rejectedWith 'OK'
        
    it 'thrown error async in first action', ->
      session ->
        await @call ->
          new Promise (resolve, reject) ->
            setImmediate -> reject Error 'OK'
        @call ->
          throw Error 'KO'
      .should.be.rejectedWith 'OK'
