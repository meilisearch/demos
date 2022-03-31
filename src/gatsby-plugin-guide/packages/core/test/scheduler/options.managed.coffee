
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.options.managed', ->
  return unless tags.api
  return
  
  describe '`false`, default', ->
  
    it 'rejected promise', ->
      stack = []
      scheduler = schedule()
      await scheduler.push -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      try
        await scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error 'catchme'
      catch err
        stack.push err.message
      await scheduler.push -> new Promise (resolve) ->
        stack.push 3
        resolve 3
      scheduler
      .should.be.resolved()
      .then -> stack.should.eql [1, 2, 'catchme', 3]
      
    it 'rejected promise in last child', ->
      stack = []
      scheduler = schedule()
      await scheduler.push -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      try
        await scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error 'catchme'
      catch err
        stack.push err.message
      scheduler
      .should.be.resolved()
      .then -> stack.should.eql [1, 2, 'catchme']
  
  describe 'managed scheduler', ->
    
    describe 'push managed handler', ->

      it 'scheduler stop on first rejected error', ->
        stack = []
        scheduler = schedule(null, managed: true)
        scheduler.push -> new Promise (resolve) ->
          stack.push 1
          resolve 1
        scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error 'catchme'
        scheduler.push -> new Promise (resolve) ->
          stack.push 3
          resolve 3
        scheduler
        .should.be.rejectedWith 'catchme'
        .then -> stack.should.eql [1, 2]
      
      it 'scheduler stop on first thrown error', ->
        stack = []
        scheduler = schedule(null, managed: true)
        scheduler.push ->
          stack.push 1
          true
        scheduler.push ->
          stack.push 2
          throw Error 'catchme'
        scheduler.push ->
          stack.push 3
          true
        scheduler
        .should.be.rejectedWith 'catchme'
        .then -> stack.should.eql [1, 2]

      it 'scheduler stop when an array reject an error', ->
        stack = []
        scheduler = schedule(null, managed: true)
        scheduler.push [
            ->
              stack.push 1
              new Promise (resolve, reject) -> resolve()
            ->
              stack.push 2
              new Promise (resolve, reject) -> reject Error 'catchme'
            ->
              stack.push 3
              new Promise (resolve, reject) -> resolve()
          ]
        .should.be.rejectedWith 'catchme'
        .then -> stack.should.eql [1, 2]
          
      it 'dont accept handler once fulfilled', ->
        scheduler = schedule(null, managed: true)
        scheduler.push -> new Promise (resolve) ->
          resolve()
        scheduler
        .then ->
          scheduler.push (->)
          .should.be.rejectedWith
            code: 'SCHEDULER_RESOLVED'
            message: [
              'SCHEDULER_RESOLVED:'
              'cannot execute a new handler,'
              'scheduler already in resolved state.'
            ].join ' '
              
      it 'dont accept handler once rejected', ->
        scheduler = schedule(null, managed: true)
        scheduler.push -> new Promise (resolve, reject) ->
          reject()
        scheduler
        .catch ->
          scheduler.push (->)
          .should.be.rejectedWith
            code: 'SCHEDULER_RESOLVED'
            message: [
              'SCHEDULER_RESOLVED:'
              'cannot execute a new handler,'
              'scheduler already in resolved state.'
            ].join ' '
          
    describe 'push unmanaged handler', ->

      it 'are called but not returnd', ->
        stack = []
        scheduler = schedule(null, managed: true)
        scheduler.push -> new Promise (resolve) ->
          stack.push 1
          resolve 1
        scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          resolve 2
        handler = scheduler.push
          handler: ->
            new Promise (resolve) ->
              resolve [...stack, 3]
          managed: false
        scheduler
        .should.be.resolvedWith [1, 2]
        .then ->
          handler
          .should.be.resolvedWith [1, 2, 3]

      it 'are called after an error', ->
        stack = []
        scheduler = schedule(null, managed: true)
        scheduler.push -> new Promise (resolve) ->
          stack.push 1
          resolve 1
        scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error stack.join ','
        prom = scheduler.push
          handler: ->
            new Promise (resolve) ->
              stack.push 3
              resolve [...stack, 3]
          managed: false
        scheduler
        .should.be.rejectedWith '1,2'
        .catch ->
          prom.should.be.resolvedWith [1, 2, 3]
        
