
# `nikita.ldap.search`

Opens a connection to an LDAP server, binds, and performs a search using
specified parameters. 

## Example

```js
const {stdout} = await nikita.ldap.search({
  base: 'dc=example,dc=org'
})
console.info(stdout)
// dn: dc=example,dc=org
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'attributes':
            type: 'array'
            items: type: 'string'
            default: []
            description: '''
            List of attributes to return, default to all.
            '''
          'continuous':
            type: 'boolean'
            description: '''
            Continuous  operation  mode.  Errors  are reported, but ldapsearch
            will continue with searches.
            '''
          'base':
            type: 'string'
            description: '''
            One or multiple DN to remove.
            '''
          'filter':
            type: 'string'
            description: '''
            The filter should conform to the string representation for search
            filters as defined in RFC 4515. If not provided, the default filter,
            (objectClass=*), is used.
            '''
          'scope':
            type: 'string'
            enum: ['base', 'one', 'sub', 'children']
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
          'mesh':
            type: 'string'
            description: '''
            Specify the SASL mechanism to be used for authentication. If it's not
            specified, the program will choose the best  mechanism  the  server
            knows.
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
        required: ['base']

## Handler

    handler = ({config}) ->
      # Auth related config
      if config.uri is true
        config.mesh ?= 'EXTERNAL'
        config.uri = 'ldapi:///'
      # Add related config
      await @execute config, [
        'ldapsearch'
        '-o ldif-wrap=no'
        '-LLL' # Remove comments
        '-c' if config.continuous
        "-Y #{utils.string.escapeshellarg config.mesh}" if config.mesh
        "-D #{utils.string.escapeshellarg config.binddn}" if config.binddn
        "-w #{utils.string.escapeshellarg config.passwd}" if config.passwd
        "-H #{utils.string.escapeshellarg config.uri}" if config.uri
        "-b #{utils.string.escapeshellarg config.base}"
        "-s #{utils.string.escapeshellarg config.scope}" if config.scope
        "#{utils.string.escapeshellarg config.filter}" if config.filter
        ...(
          config.attributes.map utils.string.escapeshellarg
        )
        '2>/dev/null'
      ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
        shy: true
        definitions: definitions

## Dependencies

    utils = require './utils'
