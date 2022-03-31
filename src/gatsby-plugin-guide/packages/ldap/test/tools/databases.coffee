
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require '../test'
they = require('mocha-they')(config)

return unless tags.ldap

describe 'ldap.databases', ->
  
  they 'create a new index', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {databases} = await @ldap.tools.databases
        suffix: ldap.suffix_dn
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      for database in databases
        database.should.match /^\{-?\d+\}\w+$/
