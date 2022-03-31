
{tags} = require '../test'
schedule = require '../../src/schedulers'

describe 'scheduler.options.parallel', ->
  return unless tags.api
  return
  
  run = (parallel, expect) ->
    scheduler = schedule(null, parallel: parallel, managed: true)
    for i in [0...5] then do(i) ->
      scheduler.push
        handler: (index) ->
          expect.push ['start', scheduler.state.running, scheduler.state.pending, scheduler.state.resolved]
          new Promise (resolve) ->
            setTimeout ->
              expect.push ['end', scheduler.state.running, scheduler.state.pending, scheduler.state.resolved]
              resolve 1
            , 20*i
    scheduler
  
  it 'sequential with `1`', ->
    expect = []
    run(1, expect)
    .should.be.fulfilled().then ->
      expect.should.eql [
        [ 'start', 1, 4, 0 ]
        [   'end', 1, 4, 0 ]
        [ 'start', 1, 3, 1 ]
        [   'end', 1, 3, 1 ]
        [ 'start', 1, 2, 2 ]
        [   'end', 1, 2, 2 ]
        [ 'start', 1, 1, 3 ]
        [   'end', 1, 1, 3 ]
        [ 'start', 1, 0, 4 ]
        [   'end', 1, 0, 4 ]
      ]
    
  it 'sequential with `false`', ->
    expect = []
    run(false, expect)
    .should.be.fulfilled().then ->
      expect.should.eql [
        [ 'start', 1, 4, 0 ]
        [   'end', 1, 4, 0 ]
        [ 'start', 1, 3, 1 ]
        [   'end', 1, 3, 1 ]
        [ 'start', 1, 2, 2 ]
        [   'end', 1, 2, 2 ]
        [ 'start', 1, 1, 3 ]
        [   'end', 1, 1, 3 ]
        [ 'start', 1, 0, 4 ]
        [   'end', 1, 0, 4 ]
      ]
  
  it 'concurrent with `>1`', ->
    expect = []
    run(3, expect)
    .should.be.fulfilled().then ->
      expect.should.eql [
        [ 'start', 3, 2, 0 ]
        [ 'start', 3, 2, 0 ]
        [ 'start', 3, 2, 0 ]
        [   'end', 3, 2, 0 ]
        [ 'start', 3, 1, 1 ]
        [   'end', 3, 1, 1 ]
        [ 'start', 3, 0, 2 ]
        [   'end', 3, 0, 2 ]
        [   'end', 2, 0, 3 ]
        [   'end', 1, 0, 4 ]
      ]
      
  it 'parallel with `-1`', ->
    expect = []
    run(-1, expect)
    .should.be.fulfilled().then ->
      expect.should.eql [
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [   'end', 5, 0, 0 ]
        [   'end', 4, 0, 1 ]
        [   'end', 3, 0, 2 ]
        [   'end', 2, 0, 3 ]
        [   'end', 1, 0, 4 ]
      ]
      
  it 'parallel with `true`', ->
    expect = []
    run(true, expect)
    .should.be.fulfilled().then ->
      expect.should.eql [
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [ 'start', 5, 0, 0 ]
        [   'end', 5, 0, 0 ]
        [   'end', 4, 0, 1 ]
        [   'end', 3, 0, 2 ]
        [   'end', 2, 0, 3 ]
        [   'end', 1, 0, 4 ]
      ]
