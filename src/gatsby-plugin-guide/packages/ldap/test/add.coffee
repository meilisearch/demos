
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)

return unless tags.ldap

describe 'ldap.add', ->
  
  user =
    dn: "cn=nikita,#{ldap.suffix_dn}"
    userPassword: 'test'
    uid: 'nikita'
    objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
    shadowLastChange: '15140'
    shadowMin: '0'
    shadowMax: '99999'
    shadowWarning: '7'
    loginShell: '/bin/bash'
    uidNumber: '9610'
    gidNumber: '9610'
    homeDirectory: '/home/nikita'

  they 'add new entry', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
      {$status} = await @ldap.add
        entry: user
      $status.should.be.true()
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"

  they 'add existing entry', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
      {$status} = await @ldap.add
        entry: user
        exclude: ['userPassword']
      {$status} = await @ldap.add
        entry: user
        exclude: ['userPassword']
      $status.should.be.false()
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
