
# `nikita.ldap.modify`

Insert, modify or remove entries inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.modify({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,dc=company,dc=com',
  passwd: 'secret',
  operations: [{
    'dn': 'cn=my_group,ou=groups,dc=company,dc=com'
    'changetype': 'modify',
    'values': [{
      'replace': 'gidNumber',
      'gidNumber': 9602,
    }]
  }]
})
console.log(`Entry modified: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.operations = [config.operations] unless Array.isArray config.operations

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'operations':
            type: 'array'
            items:
              type: 'object'
              properties:
                'changetype':
                  type: 'string'
                  enum: ['add', 'modify', 'remove']
                  description: '''
                  Valid operation type
                  '''
                'attributes':
                  type: 'array'
                  items:
                    type: 'object'
                    properties:
                      'type':
                        type: 'string'
                        enum: ['add', 'delete', 'replace']
                        description: '''
                        Operation type.
                        '''
                      'name':
                        type: 'string'
                        description: '''
                        Attribute name.
                        '''
                      'value':
                        type: 'string'
                        description: '''
                        Attribute value.
                        '''
                    required: ['type', 'name']
                  description: '''
                  List of attribute operations
                  '''
            description: '''
            Object to be inserted, modified or removed.
            '''
          exclude:
            type: 'array'
            items: type: 'string'
            default: []
            description: '''
            List of attribute to not compare, eg `userPassword`.
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
        required: ['operations']

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
      originals = []
      for operation in config.operations
        unless config.shortcut
          {stdout} = await @ldap.search config,
            base: operation.dn
          originals.push stdout
        # Generate ldif content
        ldif += '\n'
        ldif += "dn: #{operation.dn}\n"
        ldif += "changetype: modify\n"
        for attribute in operation.attributes
          ldif += "#{attribute.type}: #{attribute.name}\n"
          ldif += "#{attribute.name}: #{attribute.value}\n" if attribute.value
          ldif += '-\n'
      result = await @execute
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
      status = false
      for operation, i in config.operations
        unless config.shortcut
          {stdout} = await @ldap.search config,
            base: operation.dn
          status = true unless stdout is originals[i]
      status

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'ldap'
      definitions: definitions

## Dependencies

    {compare} = require 'mixme'
    utils = require './utils'
