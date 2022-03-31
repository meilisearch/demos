
nikita = require '../../src'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'actions.wait', ->
  return unless tags.api

  they 'time as main argument', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {before} = await @call ->
        before: Date.now()
      await @wait 200
      await @wait '200'
      await @wait 0
      interval = Date.now() - before
      (interval >= 400 and interval < 600).should.be.true()

  they 'validate argument', ({ssh}) ->
    before = Date.now()
    nikita
      $ssh: ssh
    .wait
      time: 'an': 'object'
    .should.be.rejectedWith [
      'NIKITA_SCHEMA_VALIDATION_CONFIG:'
      'one error was found in the configuration of action `wait`:'
      '#/definitions/config/properties/time/type config/time must be integer,'
      'type is "integer".'
    ].join ' '
