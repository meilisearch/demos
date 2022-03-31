
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.output.$logs', ->
  return unless tags.api
  
  it 'return logs', ->
    nikita ->
      {$logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      $logs.some (log) ->
        log.type is 'text' and log.key is 'value'
      .should.be.true()
        
  it 'dont alter file and filename', ->
    nikita ->
      {$logs} = await @call ({tools: {log}}) ->
        log key: 'value'
        true
      $logs.some (log) ->
        log.file.should.eql 'logs.coffee'
        log.filename.should.eql __filename
        
  it 'return logs in error', ->
    nikita ->
      try
        await @call ({tools: {log}}) ->
          log key: 'value'
          throw Error 'catchme'
      catch err
        err.message.should.eql 'catchme'
        err.$logs.some (log) ->
          log.type is 'text' and log.key is 'value'
        .should.be.true()
