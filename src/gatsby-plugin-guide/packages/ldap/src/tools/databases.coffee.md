
# `nikita.ldap.tools.databases`

List the databases of the OpenLDAP server. It returns the `olcDatabase` value.

## Example

```js
const {databases} = await nikita.ldap.tools.databases({
  uri: 'ldap://localhost',
  binddn: 'cn=admin,cn=config',
  passwd: 'config'
})
// Value is similar to `[ '{-1}frontend', '{0}config', '{1}mdb' ]`
databases.map( database => {
  console.info(`Database: ${database}`)
})
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        allOf: [
          properties:
            'base':
              const: 'cn=config'
              default: 'cn=config'
        ,
          $ref: 'module://@nikitajs/ldap/src/search'
        ]

## Handler

    handler = ({config}) ->
      {stdout} = await @ldap.search config,
        base: config.base
        filter: '(objectClass=olcDatabaseConfig)'
        attributes: ['olcDatabase']
      databases = utils.string
      .lines stdout
      .filter (line) -> /^olcDatabase: /.test line
      .map (line) -> line.split(' ')[1]
      databases: databases

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
        definitions: definitions

## Dependencies

    utils = require '../utils'
