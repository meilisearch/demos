
# `nikita.ipa.user.enable`

Enable a user from FreeIPA. Status is false if the user is already enabled.

## Example

```js
const {$status} = await nikita.ipa.user.enable({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was enable: ${$status}`)
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
      {result: {nsaccountlock}} = await @ipa.user.show
        $shy: false
        connection: config.connection
        uid: config.uid
      return false if nsaccountlock is false
      await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: "user_enable/1"
          params: [[config.uid], {}]
          id: 0

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
