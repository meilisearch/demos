
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require '../test'
they = require('mocha-they')(config)

return unless tags.ldap

describe 'ldap.database', ->
  
  describe 'schema', ->
    
    it 'require `suffix`', ->
      nikita.ldap.tools.database
        uri: ldap.uri
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config must have required property 'suffix'/
    
    it 'extends ldap.search', ->
      nikita.ldap.tools.database
        uri: invalid: 'value'
        suffix: ldap.suffix_dn
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config\/uri must be string/
    
    it 'provide an immutable value to `base`', ->
      nikita.ldap.tools.database
        base: 'invalid'
        suffix: ldap.suffix_dn
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config\/base must be equal to constant, allowedValue is "cn=config"/
      
  
  describe 'usage', ->
  
    they 'create a new index', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {dn, database} = await @ldap.tools.database
          suffix: ldap.suffix_dn
          uri: ldap.uri
          binddn: ldap.config.binddn
          passwd: ldap.config.passwd
        dn.should.match /^olcDatabase=\{\d+\}\w+,cn=config$/
        database.should.match /^\{\d+\}\w+$/
