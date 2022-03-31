
# `nikita.krb5.ticket`

Renew the Kerberos ticket of a user principal inside a Unix session.

## Example

```js
const {$status} = await nikita.krb5.ticket({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
})
console.info(`ticket was renewed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/gid'
          'principal':
            type: 'string'
            description: '''
            The principal the ticket to be renewed.
            '''
          'password':
            type: 'string'
            description: '''
            Password associated to this principal.
            '''
          'keytab':
            type: 'string'
            description: '''
            Path to the file storing key entries.
            '''
          'uid':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/uid'
        oneOf: [
          {required: ['keytab']}
          {required: ['password']}
        ]

## Handler

    handler = ({config}) ->
      await @execute
        command: """
        if #{utils.krb5.su config, 'klist -s'}; then exit 3; fi
        #{utils.krb5.kinit config}
        """
        code_skipped: 3
      return unless (config.uid? or config.gid?) and config.keytab?
      await @fs.chown
        uid: config.uid
        gid: config.gid
        target: config.keytab

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'krb5'
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/krb5/lib/utils'
    {mutate} = require 'mixme'
