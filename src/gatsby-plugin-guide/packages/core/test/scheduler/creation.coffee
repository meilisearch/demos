
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.creation', ->
  return unless tags.api
  return
  
  describe 'usage', ->
  
    it 'is a promise', ->
      schedule()
      .should.be.a.Promise()
  
  describe 'resolve', ->
      
    it 'accept handlers in its arguments', ->
      schedule([
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> accept 2
      ])
      .should.be.resolvedWith [1, 2]
        
    it 'accept empty array', ->
      schedule([])
      .should.be.resolvedWith []
        
    it 'accept null', ->
      schedule([])
      .should.be.resolvedWith []
    
    it 'not affected by push', ->
      scheduler = schedule()
      scheduler.push [
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> accept 2
      ]
      scheduler.push -> new Promise (accept) ->  accept 3
      scheduler
      .should.be.resolvedWith undefined
    
  describe 'error', ->

    it 'first', ->
      schedule([
        -> new Promise (accept, reject) -> reject Error 'catchme'
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> setImmediate accept 2
      ])
      .should.be.rejectedWith 'catchme'

    it 'middle', ->
      schedule([
        -> new Promise (accept, reject) -> reject Error 'catchme'
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> setImmediate accept 2
      ])
      .should.be.rejectedWith 'catchme'

    it 'last', ->
      schedule([
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> setImmediate accept 2
        -> new Promise (accept, reject) -> reject Error 'catchme'
      ])
      .should.be.rejectedWith 'catchme'
