
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)

return unless tags.ldap_user

describe 'ldap.modify', ->
  
  they 'entry with password', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      entry =
        dn: "cn=nikita,#{ldap.suffix_dn}"
        userPassword: 'secret'
        uid: 'nikita'
        objectClass: [ 'top', 'account', 'posixAccount' ]
        uidNumber: '9610'
        gidNumber: '9610'
        homeDirectory: '/home/nikita'
      operations = [
        dn: entry.dn
        changetype: 'modify'
        attributes: [
          type: 'replace'
          name: 'userPassword'
          value: 'newsecret'
        ]
      ]
      @ldap.delete
        dn: entry.dn
      {$status} = await @ldap.add
        entry: entry
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.true()
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.false()
      @ldap.delete
        dn: entry.dn
    
  they 'entry with array', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      $ssh: ssh
    , ->
      entry =
        dn: "cn=nikita,#{ldap.suffix_dn}"
        objectClass: [ 'top', 'posixGroup' ]
        cn: 'nikita'
        gidNumber: '3000'
        memberUid: '4001'
      operations = [
        dn: entry.dn
        changetype: 'modify'
        attributes: [
          type: 'replace'
          name: 'memberUid'
          value: '4002'
        ,
          type: 'add'
          name: 'memberUid'
          value: '4003'
        ]
      ]
      @ldap.delete
        dn: entry.dn
      {$status} = await @ldap.add
        entry: entry
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.true()
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.false()
      @ldap.delete
        dn: entry.dn
