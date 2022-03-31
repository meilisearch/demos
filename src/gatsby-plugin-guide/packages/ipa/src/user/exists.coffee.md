
# `nikita.ipa.user.exists`

Check if a user exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.user.exists({
  uid: 'someone',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User exists: ${$status}`)
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
            Name of the user to check for existence, same as the `username`.
            '''
          'username':
            type: 'string'
            description: '''
            Name of the user to check for existence, alias of `uid`.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['connection', 'uid']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      try
        await @ipa.user.show
          connection: config.connection
          uid: config.uid
        $status: true, exists: true
      catch err
        throw err if err.code isnt 4001 # user not found
        $status: false, exists: false

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
        shy: true
