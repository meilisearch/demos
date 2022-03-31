
# `nikita.ldap.user`

Create and modify a user store inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.user({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  user: {}
})
console.info(`User created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'string'
            description: '''
            Distinguish name storing the "olcAccess" property, using the database
            address (eg: "olcDatabase={2}bdb,cn=config").
            '''
          'user':
            oneOf: [
              type: 'object'
            ,
              type: 'array'
            ]
            description: '''
            User object.
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
            oneOf: [
              {type: 'string'}
              {type: 'boolean', default: 'ldapi:///'}
            ]
            description: '''
            LDAP Uniform Resource Identifier(s), "ldapi:///" if true, default to
            false in which case it will use your openldap client environment
            configuration.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      # Auth related config
      # binddn = if config.binddn then "-D #{config.binddn}" else ''
      # passwd = if config.passwd then "-w #{config.passwd}" else ''
      # uri = if config.uri then "-H #{config.uri}" else '' # URI is obtained from local openldap conf unless provided
      # User related config
      # Note, very weird, if we don't merge, the user array is traversable but
      # the keys map to undefined values.
      config.user = [merge config.user] unless Array.isArray config.user
      modified = false
      for user in config.user
        # Add the user
        entry = {}
        for k, v of user
          continue if k is 'userPassword' and not /^\{SASL\}/.test user.userPassword
          entry[k] = user[k]
        {updated, added} = await @ldap.add
          entry: entry
          uri: config.uri
          binddn: config.binddn
          passwd: config.passwd
        if added then log message: "User added", level: 'WARN', module: 'nikita/ldap/user'
        else if updated then log message: "User updated", level: 'WARN', module: 'nikita/ldap/user'
        modified = true if updated or added
        # Check password is user is not new and his password is not of type SASL
        new_password = false
        if not added and user.userPassword and not /^\{SASL\}/.test user.userPassword
          {$status: loggedin} = await @ldap.search
            # See https://onemoretech.wordpress.com/2011/09/22/verifying-ldap-passwords/
            binddn: user.dn
            passwd: user.userPassword
            uri: config.uri
            base: ''
            scope: 'base'
            filter: 'objectclass=*'
            code_skipped: 49
          new_password = true unless loggedin
        if added or new_password and not /^\{SASL\}/.test user.userPassword
          await @execute
            command: [
              'ldappasswd'
              "-Y #{utils.string.escapeshellarg config.mesh}" if config.mesh
              "-D #{utils.string.escapeshellarg config.binddn}" if config.binddn
              "-w #{utils.string.escapeshellarg config.passwd}" if config.passwd
              "-H #{utils.string.escapeshellarg config.uri}" if config.uri
              "-s #{user.userPassword}"
              "#{utils.string.escapeshellarg user.dn}"
            ].join ' '
          log message: "Password modified", level: 'WARN'
          modified = true
      $status: modified

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
        definitions: definitions

## Note

A user can modify it's own password with the "ldappasswd" command if ACL allows
it. Here's an example:

```bash
ldappasswd -D cn=myself,ou=users,dc=ryba -w oldpassword \
  -H ldaps://master3.ryba:636 \
  -s newpassword 'cn=myself,ou=users,dc=ryba'
```

## Dependencies

    {merge} = require 'mixme'
    utils = require './utils'

[index]: http://www.zytrax.com/books/ldap/apa/indeces.html
