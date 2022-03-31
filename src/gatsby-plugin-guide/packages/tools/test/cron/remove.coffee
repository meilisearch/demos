
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_cron

describe 'tools.cron.remove', ->

  describe 'schema', ->

    it 'invalid job: no command', ->
      nikita
      .service 'cronie'
      .tools.cron.remove
        when: '1 2 3 4 5'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `tools.cron.remove`:'
          '#/definitions/config/required config must have required property \'command\'.'
        ].join ' '

  describe 'action', ->

    rand = Math.random().toString(36).substring(7)

    they 'remove a job', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service 'cronie'
        @tools.cron.add
          command: "/bin/true #{rand}/toto - *.mp3"
          when: '0 * * * *'
        {$status} = await @tools.cron.remove
          command: "/bin/true #{rand}/toto - *.mp3"
          when: '0 * * * *'
        $status.should.be.true()
        {$status} = await @tools.cron.remove
          command: "/bin/true #{rand}/toto - *.mp3"
          when: '0 * * * *'
        $status.should.be.false()
