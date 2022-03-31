
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.time', ->
  return unless tags.api
  
  it 'start and end time', ->
    nikita ->
      @call ({metadata: {time_start, time_end}}) ->
        (time_end is undefined).should.be.true()
        time_start.should.be.a.Number()
      @call ({sibling: {metadata: {time_end}}}) ->
        time_end.should.be.a.Number()
        
  it 'start time greater than end time', ->
    nikita ->
      start = 0
      @call ({metadata: {time_start}}) ->
        time_start.should.not.eql 0
        start = time_start
        @wait 10
      @call ({sibling: {metadata: {time_end}}}) ->
        time_end.should.be.above start
