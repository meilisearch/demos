
# `nikita.ipa.group.exists`

Check if a group exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group.exists({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group exists: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cn':
            type: 'string'
            description: '''
            Name of the group to check for existence.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['cn', 'connection']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      try
        await @ipa.group.show
          connection: config.connection
          cn: config.cn
        $status: true, exists: true
      catch err
        throw err if err.code isnt 4001 # group not found
        $status: false, exists: false
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
