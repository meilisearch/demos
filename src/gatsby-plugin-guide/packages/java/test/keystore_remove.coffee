
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'java.keystore_remove', ->
  
  describe 'schema and config', ->
    
    it 'either name of cname is required', ->
      await nikita.java.keystore_remove
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        caname: "ok"
      .should.be.fulfilled()
      await nikita.java.keystore_remove
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        name: "ok"
      .should.be.fulfilled()
      await nikita.java.keystore_remove
        keystore: "ok"
        storepass: "ok"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'multiple errors were found in the configuration of action `java.keystore_remove`:'
        '#/definitions/config/anyOf config must match a schema in anyOf;'
        '#/definitions/config/anyOf/0/required config must have required property \'name\';'
        '#/definitions/config/anyOf/1/required config must have required property \'caname\'.'
      ].join ' '

    they 'keystore doesnt need to exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_remove
          keystore: "#{tmpdir}/does/not/exist"
          storepass: "invalid"
          caname: "invalid"
        $status.should.be.false()
          
    they 'caname and name are provided', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @java.keystore_remove
          keystore: "invalid"
          storepass: "invalid"
          caname: "my_caname"
          name: "my_name"

  describe 'cacert', ->

    they 'remove cacerts', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        keystore =  "#{tmpdir}/cacerts"
        caname = 'my_alias'
        storepass = 'changeit'
        await @java.keystore_add
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          caname: "#{caname}"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        {$status} = await @java.keystore_remove
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          caname: "#{caname}"
        $status.should.be.true()
        {$status} = await @java.keystore_remove
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          caname: "#{caname}"
        $status.should.be.false()
        await @execute
          command: """
          keytool -list -keystore #{keystore} -storepass #{storepass} -alias #{caname}
          """
          code: 1

  describe 'key', ->

    they 'remove cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        keystore =  "#{tmpdir}/cacerts"
        caname = 'my_alias'
        storepass = 'changeit'
        keypass = 'mypassword'
        name = 'node_1'
        await @java.keystore_add
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          caname: "#{caname}"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: "#{name}"
        {$status} = await @java.keystore_remove
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          name: "#{name}"
          keypass: "#{keypass}"
        $status.should.be.true()
        {$status} = await @java.keystore_remove
          keystore: "#{keystore}"
          storepass: "#{storepass}"
          name: "#{name}"
          keypass: "#{keypass}"
        $status.should.be.false()
        await @execute
          command: """
          keytool -list -keystore #{keystore} -storepass #{storepass} -alias #{name}
          """
          code: 1
