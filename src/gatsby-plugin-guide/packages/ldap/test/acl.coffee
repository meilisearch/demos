
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)
utils = require '../src/utils'

return unless tags.ldap_acl

describe 'ldap.acl', ->
  
  client = olcAccesses = olcDatabase = null
  beforeEach ->
    {database: olcDatabase} = await nikita.ldap.tools.database
      uri: ldap.uri
      binddn: ldap.config.binddn
      passwd: ldap.config.passwd
      suffix: ldap.suffix_dn
    {stdout} = await nikita.ldap.search
      uri: ldap.uri
      binddn: ldap.config.binddn
      passwd: ldap.config.passwd
      base: "olcDatabase=#{olcDatabase},cn=config"
      attributes: ['olcAccess']
      scope: 'base'
    olcAccesses = utils.string.lines(stdout)
    .filter (l) -> /^olcAccess: /.test l
    .map (line) -> line.split(':')[1].trim()
  afterEach ->
    nikita.ldap.modify
      uri: ldap.uri
      binddn: ldap.config.binddn
      passwd: ldap.config.passwd
      operations:
        dn: "olcDatabase=#{olcDatabase},cn=config"
        changetype: 'modify'
        attributes: [
          type: 'delete'
          name: 'olcAccess'
          ...(
            type: 'add'
            name: 'olcAccess'
            value: olcAccess
          ) for olcAccess in olcAccesses
        ]

  they 'create a new permission', ({ssh}) ->
    nikita
      ldap:
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      $ssh: ssh
    , ->
      {$status} = await @ldap.acl
        suffix: ldap.suffix_dn
        acls:
          to: 'dn.base="dc=test,dc=com"'
          by: [
            'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
          ]
      $status.should.be.true()
      {$status} = await @ldap.acl
        suffix: ldap.suffix_dn
        acls:
          to: 'dn.base="dc=test,dc=com"'
          by: [
            'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
          ]
      $status.should.be.false()

  they 'respect order in creation', ({ssh}) ->
    nikita
      ldap:
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      $ssh: ssh
    , ->
      @ldap.acl
        suffix: ldap.suffix_dn
        acls:
          to: 'dn.base="ou=test1,dc=test,dc=com"'
          by: [
            'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
          ]
      @ldap.acl
        suffix: ldap.suffix_dn
        acls:
          to: 'dn.base="ou=test2,dc=test,dc=com"'
          by: [
            'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
          ]
      @ldap.acl
        suffix: ldap.suffix_dn
        acls:
          to: 'dn.base="ou=INSERTED,dc=test,dc=com"'
          place_before: 'dn.base="ou=test2,dc=test,dc=com"'
          by: [
            'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
          ]
      {dn} = await @ldap.tools.database
        suffix: ldap.suffix_dn
      {stdout} = await @ldap.search
        base: dn
        scope: 'base'
        attributes:['olcAccess']
