
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.promise', ->
  return unless tags.api
  return
  
  describe 'instantiate handlers with error', ->

    it 'from constructor', ->
      stack = []
      schedule [
        ->
          stack.push 1
          true
      ,
        ->
          stack.push 2
          throw Error 'catchme'
      ,
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1, 2]

    it 'asynchronously', ->
      stack = []
      schedule [
        ->
          stack.push 1
          true
      ,
        ->
          stack.push 2
          new Promise (resolve, reject) ->
            setTimeout ->
              reject Error 'catchme'
            , 500
      ,
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1, 2]
  
  describe 'with push', ->

    it 'array', ->
      schedule()
      .push [
          -> new Promise (resolve, reject) -> resolve()
          -> new Promise (resolve, reject) -> reject Error 'catchme'
          -> new Promise (resolve, reject) -> resolve()
        ]
      .should.be.rejectedWith 'catchme'
