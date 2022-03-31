
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.options.strict', ->
  return unless tags.api
  return
  
  it 'when `false`', ->
    scheduler = schedule(null, strict: false)
    prom1 = scheduler.push -> new Promise (resolve) ->
      resolve 1
    prom2 = scheduler.push -> new Promise (resolve, reject) ->
      reject 2
    prom3 = scheduler.push -> new Promise (resolve) ->
      resolve 3
    Promise.allSettled [prom1, prom2, prom3]
    .then (values) ->
      values.should.eql [
        {status: 'fulfilled', value: 1}
        {status: 'rejected', reason: 2}
        {status: 'fulfilled', value: 3}
      ]
      
  it 'when `true`', ->
    scheduler = schedule(null, strict: true)
    prom1 = scheduler.push -> new Promise (resolve) ->
      resolve 1
    prom2 = scheduler.push -> new Promise (resolve, reject) ->
      reject 2
    prom3 = scheduler.push -> new Promise (resolve) ->
      resolve 3
    Promise.allSettled [prom1, prom2, prom3]
    .then (values) ->
      values.should.eql [
        {status: 'fulfilled', value: 1}
        {status: 'rejected', reason: 2}
        {status: 'rejected', reason: 2}
      ]
