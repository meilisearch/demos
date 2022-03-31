
# `nikita.ldap.delete`

Insert or modify an entry inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.delete({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  dn: 'cn=group1,ou=groups,dc=company,dc=com'
})
console.log(`Entry deleted: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'dn':
            type: 'array'
            items: type: 'string'
            description: '''
            One or multiple DN to remove.
            '''
          'name':
            type: 'string'
            description: '''
            Distinguish name storing the "olcAccess" property, using the database
            address (eg: "olcDatabase={2}bdb,cn=config").
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
        required: ['dn']

## Handler

    handler = ({config}) ->
      # Auth related config
      binddn = if config.binddn then "-D #{config.binddn}" else ''
      passwd = if config.passwd then "-w #{config.passwd}" else ''
      config.uri = 'ldapi:///' if config.uri is true
      uri = if config.uri then "-H #{config.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Add related config
      config.dn = [config.dn] unless Array.isArray config.dn
      dn = config.dn.map( (dn) -> "'#{dn}'").join(' ')
      # ldapdelete -D cn=Manager,dc=ryba -w test -H ldaps://master3.ryba:636 'cn=nikita,ou=users,dc=ryba'
      await @execute
        # Check that the entry exists
        $if_execute: "ldapsearch #{binddn} #{passwd} #{uri} -b #{dn} -s base"
        command: "ldapdelete #{binddn} #{passwd} #{uri} #{dn}"
        # code_skipped: 68
      # modified = stderr.match(/Already exists/g)?.length isnt stdout.match(/adding new entry/g).length
      # added = modified # For now, we dont modify
      # callback err, modified, added

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
        definitions: definitions
