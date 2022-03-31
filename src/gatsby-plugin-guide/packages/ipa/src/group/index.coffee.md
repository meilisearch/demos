
# `nikita.ipa.group`

Add or modify a group in FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group was updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cn':
            type: 'string'
            description: '''
            Name of the group to add or modify.
            '''
          'attributes':
            type: 'object'
            default: {}
            description: '''
            Attributes associated with the group to add or modify.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['cn', 'connection']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {$status} = await @ipa.group.exists
        connection: config.connection
        cn: config.cn
      # Add or modify a group
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: unless $status then "group_add/1" else "group_mod/1"
          params: [[config.cn], config.attributes]
          id: 0
      output = {}
      $status = false
      if data?.error
        if data.error.code isnt 4202 # no modifications to be performed
          error = Error data.error.message
          error.code = data.error.code
          throw error
      else
        output.result = data.result.result
        $status = true
      # Get result info even if no modification is performed
      unless $status
        {result} = await @ipa.group.show config,
          cn: config.cn
        output.result = result
      $status: $status, result: output.result

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
