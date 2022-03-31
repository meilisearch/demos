
# `nikita.ipa.service.exists`

Check if a service exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.service.exists({
  principal: 'myprincipal/my.domain.com',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Service exists: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'principal':
            type: 'string'
            description: '''
            Name of the service to check for existence.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['connection', 'principal']


## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      try
        await @ipa.service.show
          connection: config.connection
          principal: config.principal
        $status: true, exists: true
      catch err
        if err.code isnt 4001 # service not found
          throw err
        $status: false, exists: false
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
