
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'java.keystore_add', ->
  
  describe 'schema', ->
    
    it 'cacert implies caname', ->
      await nikita.java.keystore_add
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        cacert: "ok"
        caname: 'ok'
      await nikita.java.keystore_add
        keystore: "ok"
        storepass: "ok"
        cacert: "implies caname"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `java.keystore_add`:'
        '#/dependencies/cacert/required config must have required property \'caname\'.'
      ].join ' '
        
    it 'cert implies key, keypass and name', ->
      await nikita.java.keystore_add
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        cert: "ok"
        key: "ok"
        keypass: "ok"
        name: 'ok'
      await nikita.java.keystore_add
        keystore: "ok"
        storepass: "ok"
        cert: "implies key, keypass and name"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'multiple errors were found in the configuration of action `java.keystore_add`:'
        '#/dependencies/cert/required config must have required property \'key\';'
        '#/dependencies/cert/required config must have required property \'keypass\';'
        '#/dependencies/cert/required config must have required property \'name\'.'
      ].join ' '
  
  describe 'config', ->

    they 'caname, cacert, cert, name, key, keypass are provided', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_caname"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          name: "my_name"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          keypass: 'mypassword'
        $status.should.be.true()

  describe 'cacert', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        $status.should.be.true()

    they 'create parent directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/a/dir/cacerts"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        $status.should.be.true()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        $ssh: null
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore_add
          $shy: true
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        $status.should.be.false()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore_add
          $shy: true
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs2/cacert.pem"
        $status.should.be.true()
        await @execute.assert
          command: "keytool -list -keystore #{tmpdir}/keystore -storepass changeit -alias my_alias"
          content: /^my_alias,/m

    they 'fail if CA file does not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: '/path/to/missing/ca.cert.pem'
        .should.be.rejectedWith
          message: 'CA file does not exist: /path/to/missing/ca.cert.pem'

    they 'import certificate chain', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute
          command: """
          mkdir #{tmpdir}/tmp
          cd #{tmpdir}/tmp
          openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/keystore/certs1/cacert_key.pem -CA #{__dirname}/keystore/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
          openssl req -new -nodes -out ca_int2.req -keyout ca_int2.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int2.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2.cert.pem
          cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2.cert.pem > ca.cert.pem
          """
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/tmp/ca.cert.pem"
        $status.should.be.true()
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/tmp/ca.cert.pem"
        $status.should.be.false()
        await @execute.assert
          command: "keytool -list -keystore #{tmpdir}/keystore -storepass changeit -alias my_alias-0"
          content: /^my_alias-0,/m
        await @execute.assert
          command: "keytool -list -keystore #{tmpdir}/keystore -storepass changeit -alias my_alias-1"
          content: /^my_alias-1,/m
        await @execute.assert
          command: "keytool -list -keystore #{tmpdir}/keystore -storepass changeit -alias my_alias-2"
          content: /^my_alias-2,/m

    they 'honors status with certificate chain', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @execute
          command: """
          mkdir #{tmpdir}/ca
          cd #{tmpdir}/ca
          openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/keystore/certs1/cacert_key.pem -CA #{__dirname}/keystore/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
          openssl req -new -nodes -out ca_int2a.req -keyout ca_int2a.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int2a.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2a.cert.pem
          cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2a.cert.pem > ca.a.cert.pem
          openssl req -new -nodes -out ca_int2b.req -keyout ca_int2b.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int2b.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2b.cert.pem
          cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2b.cert.pem > ca.b.cert.pem
          """
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/ca/ca.a.cert.pem"
        $status.should.be.true()
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/ca/ca.b.cert.pem"
        $status.should.be.true()

  describe 'key', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.false()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
          key: "#{__dirname}/keystore/certs1/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs2/cacert.pem"
          key: "#{__dirname}/keystore/certs2/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs2/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()

  describe 'keystore', ->

    they.skip 'change password', ({ssh}) ->
      nikita
        $ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        {$status} = await @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changednow"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        $status.should.be.true()

  describe 'config openssl', ->

    they 'throw error if not detected', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @java.keystore_add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/keystore/certs2/cacert.pem"
          key: "#{__dirname}/keystore/certs2/node_1_key.pem"
          cert: "#{__dirname}/keystore/certs2/node_1_cert.pem"
          keypass: 'mypassword'
          openssl: '/doesnt/not/exists'
          name: 'node_1'
        .should.be.rejectedWith
          message: 'OpenSSL command line tool not detected'
