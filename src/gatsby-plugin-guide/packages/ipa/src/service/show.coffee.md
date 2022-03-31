
# `nikita.ipa.service.show`

Retrieve service information from FreeIPA.

## Example

```js
try {
  const {result} = await nikita.ipa.service.show({
    principal: "myprincipal/my.domain.com",
    connection: {
      url: "https://ipa.domain.com/ipa/session/json",
      principal: "admin@DOMAIN.COM",
      password: "mysecret"
    }
  })
  console.info(`Service is ${result.principal[0]}`)
}
catch (err){
  switch(err.code){
    case 4001:
     assert("myprincipal/my.domain.com@DOMAIN.COM: service not found", err.message)
    break
  }
}  
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'principal':
            type: 'string'
            description: '''
            Name of the service to show.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['connection', 'principal']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: 'service_show/1'
          params: [[config.principal],{}]
          id: 0
      if data.error
        error = Error data.error.message
        error.code = data.error.code
        throw error
      else
        result: data.result.result

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
