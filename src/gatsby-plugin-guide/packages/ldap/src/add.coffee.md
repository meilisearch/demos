
# `nikita.ldap.add`

Insert or modify an entry inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  entry: {
    dn: 'cn=group1,ou=groups,dc=company,dc=com'
    cn: 'group1'
    objectClass: 'top'
    objectClass: 'posixGroup'
    gidNumber: 9601
  }
})
console.info(`Entry modified: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.entry = [config.entry] unless Array.isArray config.entry

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'entry':
            type: 'array'
            items:
              type: 'object'
              properties:
                'dn':
                  type: 'string'
                  description: '''
                  Distinguish name of the entry
                  '''
              required: ['dn']
            description: '''
            Object to be inserted or modified.
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
        required: ['entry']

## Handler

    handler = ({config}) ->
      # Auth related config
      # binddn = if config.binddn then "-D #{config.binddn}" else ''
      # passwd = if config.passwd then "-w #{config.passwd}" else ''
      # config.uri = 'ldapi:///' if config.uri is true
      if config.uri is true
        config.mesh ?= 'EXTERNAL'
        config.uri = 'ldapi:///'
      uri = if config.uri then "-H #{config.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Add related config
      ldif = ''
      for entry in config.entry
        # Check if record already exists
        {$status, stdout} = await @ldap.search config,
          base: entry.dn
          code_skipped: 32 # No such object
          scope: 'base'
        original = {}
        continue if $status
        # throw Error "Nikita `ldap.add`: required property 'dn'" unless entry.dn
        ldif += '\n'
        ldif += "dn: #{entry.dn}\n"
        ldif += 'changetype: add\n'
        [_, k, v] = /^(.*?)=(.+?),.*$/.exec entry.dn
        ldif += "#{k}: #{v}\n"
        if entry[k]
          throw Error "Inconsistent value: #{entry[k]} is not #{v} for attribute #{k}" if entry[k] isnt v
          delete entry[k]
        for k, v of entry
          continue if k is 'dn'
          v = [v] unless Array.isArray v
          for vv in v
            ldif += "#{k}: #{vv}\n"
      {stdout, stderr} = await @execute
        $if: ldif isnt ''
        command: [
          [
            'ldapmodify'
            '-c' if config.continuous
            "-Y #{utils.string.escapeshellarg config.mesh}" if config.mesh
            "-D #{utils.string.escapeshellarg config.binddn}" if config.binddn
            "-w #{utils.string.escapeshellarg config.passwd}" if config.passwd
            "-H #{utils.string.escapeshellarg config.uri}" if config.uri
          ].join ' '
          """
          <<-EOF
          #{ldif}
          EOF
          """
        ].join ' '

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'ldap'
        definitions: definitions

## Dependencies

    utils = require './utils'
