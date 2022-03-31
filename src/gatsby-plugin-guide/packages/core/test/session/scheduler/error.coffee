
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.scheduler.error', ->
  return unless tags.api

  describe 'in last child', ->

    it 'return rejected promise', ->
      nikita ->
        @call ->
          @call ->
            new Promise (resolve, reject) ->
              reject Error 'catchme'
        .should.be.rejectedWith 'catchme'

    it 'await throw error', ->
      nikita ->
        @call ->
          @call ->
            await @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
        .should.be.rejectedWith 'catchme'
        
    it 'await with try/catch', ->
      nikita ->
        @call ->
          try
            await @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
          catch err
            err.message.should.eql 'catchme'
  
    it 'throw error and return valid output', ->
      nikita ->
        @call ->
          @call ->
            @call ->
              throw Error 'catchme'
            true
        .should.finally.match $status: true

    it 'reject promise and return valid output', ->
      nikita ->
        @call ->
          @call ->
            @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
            true
        .should.finally.match $status: true
  
  describe 'in array of actions', ->

    it 'array with an error sent synchronously', ->
      stack = []
      nikita.call [
        ->
          stack.push 1
          true
        ->
          stack.push 2
          throw Error 'catchme'
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1,2]

    it 'array with an error sent asynchronously', ->
      stack = []
      nikita.call [
        ->
          stack.push 1
          true
        ->
          stack.push 2
          new Promise (resolve, reject) ->
            setTimeout ->
              reject Error 'catchme'
            , 100
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1,2]
  
  describe 'error handling', ->

    it 'throw error and keep going', ->
      stack = []
      nikita ->
        # The following used to hang the scheduler
        @call (->)
        await new Promise (resolve, reject) ->
          setTimeout resolve, 10
        @call (->)

    it 'parent get the uncatched and last error', ->
      # Note, there was a bug where the last action was executed but the error
      # was swallowed
      nikita ->
        try
          await @call -> throw Error 'ok'
        catch err
        @call ->
          throw Error 'Catch me'
      .should.be.rejectedWith 'Catch me'
        
