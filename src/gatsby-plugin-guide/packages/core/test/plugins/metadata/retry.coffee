
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.retry', ->
  return unless tags.api
  
  describe 'validation', ->

    it 'ensure retry equals or is greater than 0', ->
      nikita
      .call $retry: 0, (->)
      .call $retry: 1, (->)
      .call $retry: -1, (->)
      .should.be.rejectedWith [
        'METADATA_RETRY_INVALID_RANGE:'
        'configuration `retry` expect a number above or equal to 0,'
        'got -1.'
      ].join ' '

  describe 'handler', ->

    it 'handler thrown exception', ->
      nikita.call $retry: 5, $sleep: 100, ({metadata}) ->
        if metadata.attempt < 2
        then throw Error 'Catchme'
        else "success #{metadata.attempt}"
      .should.be.resolvedWith 'success 2'

    it 'handler rejected promises', ->
      nikita.call $retry: 5, $sleep: 100, ({metadata}) ->
        new Promise (resolve, reject) ->
          if metadata.attempt < 2
          then throw Error 'Catchme'
          else resolve "success #{metadata.attempt}"
      .should.be.resolvedWith 'success 2'

    it 'validate the number of retry', ->
      count = 0
      await nikita
      .call $retry: 3, $sleep: 100, ({metadata}) ->
        metadata.attempt.should.eql count++
        throw Error 'Catchme'
      .should.be.rejectedWith 'Catchme'
      count.should.eql 3

    it.skip 'retry x times log retry attempt', ->
      logs = []
      nikita
      .on 'text', (log) -> logs.push log.message if /^Retry/.test log.message
      .call retry: 2, sleep: 100, relax: true, ->
        throw Error 'Catchme'
      .call ->
        logs.should.eql ['Retry on error, attempt 1']

    it 'retry true is unlimited', ->
      nikita.call $retry: true, $sleep: 100, ({metadata}) ->
        if metadata.attempt < 10
        then throw Error "Catchme"
        else "success #{metadata.attempt}"
      .should.be.resolvedWith 'success 10'

    it 'ensure config are immutable between retry', ->
      nikita
      .call test: 1, $retry: 3, $sleep: 100, ({metadata, config}) ->
        config.test.should.eql 1
        config.test = 2
        throw Error 'Retry' if metadata.attempt < 2
