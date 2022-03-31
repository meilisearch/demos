
nikita = require '@nikitajs/core/lib'
{tags, config, ldap} = require './test'
they = require('mocha-they')(config)
utils = require '../src/utils'

return unless tags.ldap_index

describe 'ldap.index', ->
  
  olcDatabase = olcDbIndexes = null
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
      attributes:['olcDbIndex']
      scope: 'base'
    olcDbIndexes = utils.string.lines(stdout)
    .filter (l) -> /^olcDbIndex: /.test l
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
          name: 'olcDbIndex'
          ...(
            type: 'add'
            name: 'olcDbIndex'
            value: olcDbIndex
          ) for olcDbIndex in olcDbIndexes
        ]

  they 'create a new index from dn', ({ssh}) ->
    nikita
      ldap:
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      $ssh: ssh
    , ->
      {dn} = await @ldap.tools.database
        suffix: ldap.suffix_dn
      {$status} = await @ldap.index
        dn: dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        dn: dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.false()

  they 'create a new index from suffix', ({ssh}) ->
    nikita
      ldap:
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      $ssh: ssh
    , ->
      {$status} = await @ldap.index
        suffix: ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        suffix: ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.false()

  they 'update an existing index', ({ssh}) ->
    nikita
      ldap:
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      $ssh: ssh
    , ->
      # Set initial value
      await @ldap.index
        suffix: ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      # Apply the update
      {$status} = await @ldap.index
        suffix: ldap.suffix_dn
        indexes:
          aliasedEntryName: 'pres,eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        suffix: ldap.suffix_dn
        indexes:
          aliasedEntryName: 'pres,eq'
      $status.should.be.false()
