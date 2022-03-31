
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)

return unless tags.ldap_user

describe 'ldap.user', ->

  they 'create a new user', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
      {$status} = await @ldap.user
        user:
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
      $status.should.be.true()
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"

  they 'detect no change', ({ssh}) ->
    user =
      dn: "cn=nikita,#{ldap.suffix_dn}"
      userPassword: 'test'
      uid: 'nikita'
      objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
      uidNumber: '9610'
      gidNumber: '9610'
      homeDirectory: '/home/nikita'
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
      @ldap.user
        user: user
      {$status} = await @ldap.user
        user: user
      $status.should.be.false()
      @ldap.delete
        dn: "cn=nikita,#{ldap.suffix_dn}"
