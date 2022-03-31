
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)

return unless tags.ldap

describe 'ldap.search', ->

  they 'with scope base', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      {stdout} = await @ldap.search
        base: "#{ldap.suffix_dn}"
      stdout.should.containEql 'dn: dc=example,dc=org'
