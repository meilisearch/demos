
# `nikita.system.authconfig`

authconfig provides a simple method of configuring /etc/sysconfig/network to handle NIS, as well as /etc/passwd and /etc/shadow, the files used for shadow password support. Basic LDAP, Kerberos 5, and Winbind client configuration is also provided. 

## Example

Example of a group object:

```js
const {$status} = await nikita.system.authconfig({
  properties: {
    mkhomedir: true
  }
})
console.info(`Was the configudation updated ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'properties':
            type: 'object'
            patternProperties:
              '.*': type: 'boolean'
            additionalProperties: false
            description: '''
            Key/value pairs of the properties to manage.
            '''
        required: ['properties']

## Handler

    handler = ({config}) ->
      {stdout: before} = await @execute
        shy: true
        command: [ 'authconfig', '--test' ].join ' '
        trim: true
      @execute
        shy: true
        command: [
          'authconfig', '--update'
          ...(
            Object.keys(config.properties).map (key) ->
              if config.properties[key]
              then "--enable#{key}"
              else "--disable#{key}"
          )
        ].join ' '
      {stdout: after} = await @execute
        shy: true
        command: [ 'authconfig', '--test' ].join ' '
        trim: true
      changes = diff.diffLines before, after, ignoreWhitespace: true
      changes.some (d) -> d.added or d.removed

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    diff = require 'diff'
