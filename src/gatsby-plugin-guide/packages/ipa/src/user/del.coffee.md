
# `nikita.ipa.user.del`

Delete a user from FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.user.del({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was deleted: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.uid ?= config.username
      delete config.username

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'uid':
            type: 'string'
            description: '''
            Name of the user to delete, same as the `username`.
            '''
          'username':
            type: 'string'
            description: '''
            Name of the user to delete, alias of `uid`.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['connection', 'uid']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {$status} = await @ipa.user.exists
        $shy: false
        connection: config.connection
        uid: config.uid
      return unless $status
      await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "user_del/1"
          params: [[config.uid], {}]
          id: 0

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
