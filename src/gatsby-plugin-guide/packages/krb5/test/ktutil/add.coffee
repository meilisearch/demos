
nikita = require '@nikitajs/core/lib'
{tags, config, krb5} = require '../test'
they = require('mocha-they')(config)

return unless tags.krb5_ktadd

describe 'krb5.kutil.add', ->

  describe 'schema', ->

    it 'principal, keyta and password must be provided', ->
      nikita
        krb5: admin: krb5
      , ->
        @krb5.ktutil.add {}
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors were found in the configuration of action `krb5.ktutil.add`:'
            '#/required config must have required property \'keytab\';'
            '#/required config must have required property \'password\';'
            '#/required config must have required property \'principal\'.'
          ].join ' '

  describe 'action', ->

    they 'create a new keytab', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: krb5
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @krb5.addprinc
          principal: "nikita@#{krb5.realm}"
          password: 'nikita123-1'
        {$status} = await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita.keytab"
          password: 'nikita123-1'
        $status.should.be.true()
        {$status} = await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita.keytab"
          password: 'nikita123-1'
        $status.should.be.false()

    they 'detect kvno', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: krb5
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @krb5.addprinc
          principal: "nikita@#{krb5.realm}"
          password: 'nikita123-1'
        await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita_1.keytab"
          password: 'nikita123-1'
        await @krb5.execute
          command: """
          change_password -pw nikita123-2 nikita@#{krb5.realm}
          """
        {$status} = await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita_1.keytab"
          password: 'nikita123-2'
        $status.should.be.true()
        {$status} = await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita_1.keytab"
          password: 'nikita123-2'
        $status.should.be.false()
    
    they 'change permission', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: krb5
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @krb5.addprinc
          principal: "nikita@#{krb5.realm}"
          password: 'nikita123-1'
        await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita_1.keytab"
          password: 'nikita123-1'
          mode: 0o0755
        {$status} = await @krb5.ktutil.add
          principal: "nikita@#{krb5.realm}"
          keytab: "#{tmpdir}/nikita_1.keytab"
          password: 'nikita123-1'
          mode: 0o0707
        $status.should.be.true()
