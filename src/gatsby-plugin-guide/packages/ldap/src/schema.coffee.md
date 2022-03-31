
# `nikita.ldap.schema`

Register a new ldap schema.

## Example

```js
const {$status} = await nikita.ldap.schema({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'kerberos',
  schema: '/usr/share/doc/krb5-server-ldap-1.10.3/kerberos.schema'
})
console.info(`Schema created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'string'
            description: '''
            Common name of the schema.
            '''
          'schema':
            type: 'string'
            description: '''
            Path to the schema definition.
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

    handler = ({config, metadata: {tmpdir}, tools: {log}}) ->
      # Auth related config
      binddn = if config.binddn then "-D #{config.binddn}" else ''
      passwd = if config.passwd then "-w #{config.passwd}" else ''
      config.uri = 'ldapi:///' if config.uri is true
      uri = if config.uri then "-H #{config.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Schema related config
      throw Error "Missing name" unless config.name
      throw Error "Missing schema" unless config.schema
      config.schema = config.schema.trim()
      schema = "#{tmpdir}/#{config.name}.schema"
      conf = "#{tmpdir}/schema.conf"
      ldif = "#{tmpdir}/ldif"
      {$status} = await @execute
        command: """
        ldapsearch -LLL #{binddn} #{passwd} #{uri} -b \"cn=schema,cn=config\" \
        | grep -E cn=\\{[0-9]+\\}#{config.name},cn=schema,cn=config
        """
        code: 1
        code_skipped: 0
      return false unless $status
      await @system.mkdir
        target: ldif
      log message: 'Directory ldif created', level: 'DEBUG'
      await @system.copy
        source: config.schema
        target: schema
      log message: 'Schema copied', level: 'DEBUG'
      await @file
        content: "include #{schema}"
        target: conf
      log message: 'Configuration generated', level: 'DEBUG'
      await @execute
        command: "slaptest -f #{conf} -F #{ldif}"
      log message: 'Configuration validated', level: 'DEBUG'
      {$status} = await @fs.move
        source: "#{ldif}/cn=config/cn=schema/cn={0}#{config.name}.ldif"
        target: "#{ldif}/cn=config/cn=schema/cn=#{config.name}.ldif"
        force: true
      throw Error 'No generated schema' unless $status
      log message: 'Configuration renamed', level: 'DEBUG'
      await @file
        target: "#{ldif}/cn=config/cn=schema/cn=#{config.name}.ldif"
        write: [
          match: /^dn: cn.*$/mg
          replace: "dn: cn=#{config.name},cn=schema,cn=config"
        ,
          match: /^cn: {\d+}(.*)$/mg
          replace: 'cn: $1'
        ,
          match: /^structuralObjectClass.*/mg
          replace: ''
        ,
          match: /^entryUUID.*/mg
          replace: ''
        ,
          match: /^creatorsName.*/mg
          replace: ''
        ,
          match: /^createTimestamp.*/mg
          replace: ''
        ,
          match: /^entryCSN.*/mg
          replace: ''
        ,
          match: /^modifiersName.*/mg
          replace: ''
        ,
          match: /^modifyTimestamp.*/mg
          replace: ''
        ]
      log message: 'File ldif ready', level: 'DEBUG'
      await @execute
        command: "ldapadd #{uri} #{binddn} #{passwd} -f #{ldif}/cn=config/cn=schema/cn=#{config.name}.ldif"
      log message: "Schema added: #{config.name}", level: 'INFO'

## Exports

    module.exports =
      handler: handler
      metadata:
        tmpdir: true
        global: 'ldap'
        definitions: definitions
