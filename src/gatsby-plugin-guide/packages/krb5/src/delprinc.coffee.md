
# `nikita.krb5.delprinc`

Remove a Kerberos principal and optionally its keytab.

## Example

```js
const {$status} = await nikita.krb5.delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  admin: {
    principal: 'me/admin@MY_REALM',
    password: 'pass',
    server: 'localhost'
  }
})
console.info(`Principal was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin':
            $ref: 'module://@nikitajs/krb5/src/execute#/definitions/config/properties/admin'
          'keytab':
            type: 'string'
            description: '''
            Path to the file storing key entries.
            '''
          'principal':
            type: 'string'
            description: '''
            Principal to be created.
            '''
          'realm':
            type: 'string'
            description: '''
            The realm the principal belongs to.
            '''
        required: ['principal']

## Handler

    handler = ({config}) ->
      # Normalize realm and principal for later usage of config
      config.realm ?= config.admin.principal.split('@')[1] if /.*@.*/.test config.admin.principal
      config.principal = "#{config.principal}@#{config.realm}" unless /^\S+@\S+$/.test config.principal
      # Prepare commands
      {$status} = await @krb5.execute
        $shy: true
        admin: config.admin
        command: "getprinc #{config.principal}"
        grep: new RegExp "^.*#{utils.regexp.escape config.principal}$"
      if $status
        await  @krb5.execute
          admin: config.admin
          command: "delprinc -force #{config.principal}"
      if config.keytab
        await @fs.remove
          target: config.keytab

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'krb5'
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
    {mutate} = require 'mixme'
