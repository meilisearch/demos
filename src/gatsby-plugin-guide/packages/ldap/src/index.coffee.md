
# `nikita.ldap.index`

Create new [index](index) for the OpenLDAP server.   

## Example

Using the database DN:

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  dn: 'olcDatabase={2}bdb,cn=config',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
})
console.info(`Index created or modified: ${$status}`)
```

Using the database suffix:

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  suffix: 'dc=example,dc=org',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
})
console.info(`Index created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'indexes':
            type: 'object'
            description: '''
            List of "olcDbIndex" values provided as key/value pairs.
            '''
          'dn':
            type: 'string'
            description: '''
            Distinguish name storing the "olcDbIndex" property, using the database
            address (eg: "olcDatabase={2}bdb,cn=config").
            '''
          'suffix':
            type: 'string'
            description: '''
            The suffix associated with the database (eg: "dc=example,dc=org"),
            used as an alternative to the `dn` configuration.
            '''
          # General LDAP connection information
          'binddn':
            type: 'string'
            description: '''
            Distinguished Name to bind to the LDAP directory.
            '''
          'passwd':
            type: 'string'
            description: '''
            Password for simple authentication.
            '''
          'uri':
            type: 'string'
            description: '''
            LDAP Uniform Resource Identifier(s), "ldapi:///" if true, default to
            false in which case it will use your openldap client environment
            configuration.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      modified = false
      indexes = {}
      add = {}
      modify = {}
      unless config.dn
        log message: "Get DN of the database to modify", level: 'DEBUG'
        {dn} = await @ldap.tools.database config,
          suffix: config.suffix
        config.dn = dn
        log message: "Database DN is #{dn}", level: 'INFO'
      # List all indexes of the directory
      log message: "List all indexes of the directory", level: 'DEBUG'
      {stdout} = await @ldap.search config,
        attributes: ['olcDbIndex']
        base: "#{config.dn}"
        filter: '(olcDbIndex=*)'
      for line in utils.string.lines stdout
        continue unless match = /^olcDbIndex:\s+(.*)\s+(.*)/.exec line
        [_, attrlist, indices] = match
        indexes[attrlist] = indices
      # Check for changes
      for k, v of config.indexes
        if not indexes[k]?
          add[k] = v
        else if v != indexes[k]
          modify[k] = [v, indexes[k]]
      # Apply the modifications
      if Object.keys(add).length? or Object.keys(modify).length?
        operations =
          dn: config.dn
          changetype: 'modify'
          attributes: []
        for k, v of add
          operations.attributes.push
            type: 'add'
            name: 'olcDbIndex'
            value: "#{k} #{v}"
        for k, v of modify
          operations.attributes.push
            type: 'delete'
            name: 'olcDbIndex'
            value: "#{k} #{v[1]}"
          operations.attributes.push
            type: 'add'
            name: 'olcDbIndex'
            value: "#{k} #{v[0]}"
        await @ldap.modify config,
          operations: operations

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
        definitions: definitions

## Dependencies

    utils = require './utils'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html
