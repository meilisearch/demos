
nikita = require '@nikitajs/core/lib'
{tags, config, krb5} = require './test'
they = require('mocha-they')(config)

return unless tags.krb5_addprinc

describe 'krb5.ticket', ->

  describe 'schema', ->

    it 'password or keytab must be provided', ->
      nikita
        krb5: admin: krb5
      , ->
        @krb5.ticket {}
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors were found in the configuration of action `krb5.ticket`:'
            '#/oneOf config must match exactly one schema in oneOf, passingSchemas is null;'
            '#/oneOf/0/required config must have required property \'keytab\';'
            '#/oneOf/1/required config must have required property \'password\'.'
          ].join ' '

  describe 'action', ->

    they 'create a new ticket with password', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: krb5
      , ->
        await @krb5.delprinc
          principal: "nikita@#{krb5.realm}"
        await @krb5.addprinc
          principal: "nikita@#{krb5.realm}"
          password: 'myprecious'
        await @execute 'kdestroy'
        {$status} = await @krb5.ticket
          principal: "nikita@#{krb5.realm}"
          password: 'myprecious'
        $status.should.be.true()
        {$status} = await @krb5.ticket
          principal: "nikita@#{krb5.realm}"
          password: 'myprecious'
        $status.should.be.false()
        await @execute
          command: 'klist -s'

    they 'create a new ticket with a keytab', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: krb5
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @krb5.delprinc
          principal: "nikita@#{krb5.realm}"
        await @krb5.addprinc
          principal: "nikita@#{krb5.realm}"
          password: 'myprecious'
          keytab: "#{tmpdir}/nikita.keytab"
        await @execute 'kdestroy'
        {$status} = await @krb5.ticket
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita.keytab"
        $status.should.be.true()
        {$status} = await @krb5.ticket
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita.keytab"
        $status.should.be.false()
        await @execute
          command: 'klist -s'
