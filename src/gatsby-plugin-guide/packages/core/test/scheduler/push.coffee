
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.push', ->
  return unless tags.api
  return

  describe 'returned value', ->

    it 'function return a promise', ->
      scheduler = schedule()
      scheduler.push (->)
      .should.be.a.Promise()

    it 'array return a promise', ->
      scheduler = schedule()
      scheduler.push [ (->) ]
      .should.be.a.Promise()

    it 'run asynchronously', ->
      stack = []
      scheduler = schedule(null)
      task = scheduler.push ->
        stack.push 2
        new Promise (accept, reject) ->
          accept()
      stack.push 1
      task.then ->
        stack.should.eql [1, 2]

  describe 'push parallel error', ->

    it.skip 'function', ->
      scheduler = schedule()
      # scheduler.push ->
      #   console.log '1 called'
      #   new Promise (resolve, reject) -> reject Error 1
      # scheduler.push ->
      #   console.log '2 not called'
      #   new Promise (resolve, reject) -> reject Error 2
      # null
      (await Promise.allSettled [
        scheduler.push -> new Promise (resolve, reject) -> reject Error 1
        scheduler.push -> new Promise (resolve, reject) -> reject Error 2
      ])
      # .map (e) -> e.reason.message
      # .should.eql ['1', '2']

    it.skip 'an array', ->
      scheduler = schedule()
      (await Promise.allSettled [
        scheduler.push [
          -> new Promise (resolve, reject) -> reject Error 1
          -> new Promise (resolve, reject) -> reject Error 2
        ]
        scheduler.push [
          -> new Promise (resolve, reject) -> resolve 3
          -> new Promise (resolve, reject) -> reject Error 4
        ]
      ])
      .map (e) -> e.reason.message
      .should.eql ['1', '4']

  describe 'push parallel sync', ->

    it 'function', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> new Promise (resolve) -> resolve 1
          scheduler.push -> new Promise (resolve) -> resolve 2
        ]
      .should.be.resolvedWith [1, 2]

    it 'an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push [
            -> new Promise (resolve) -> resolve 1
            -> new Promise (resolve) -> resolve 2
          ]
          scheduler.push [
            -> new Promise (resolve) -> resolve 3
            -> new Promise (resolve) -> resolve 4
          ]
        ]
      .should.be.resolvedWith [[1, 2], [3, 4]]

    it 'an empty array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push []
          scheduler.push []
        ]
      .should.be.resolvedWith [[], []]

  describe 'push parallel async', ->

    it 'function', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
        ]
      .should.be.resolvedWith [1, 2, 3]

    it 'an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push [
            -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
          ]
          scheduler.push [
            -> new Promise (resolve) -> setTimeout (-> resolve 4), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 5), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 6), 50
          ]
        ]
      .should.be.resolvedWith [[1, 2, 3], [4, 5, 6]]
    
