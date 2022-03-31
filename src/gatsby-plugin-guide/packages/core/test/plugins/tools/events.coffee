
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.events', ->
  return unless tags.api
  
  it 'emit events', ->
    nikita ({tools: {events}}) ->
      new Promise (resolve) ->
        events.on 'my_event', (msg) ->
          resolve msg
        events.emit 'my_event', 'getme'
      .should.be.resolvedWith 'getme'
