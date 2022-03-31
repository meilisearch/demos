
# `nikita.ipa.user`

Add or modify a user in FreeIPA.

## Implementation

The `userpassword` attribute is only used on user creation. To force the
password to be re-initialized on user update, pass the `force_userpassword`
option.

## Example

```js
const {$status} = await nikita.ipa.user({
  uid: "someone",
  attributes: {
    noprivate: true,
    gidnumber: 1000,
    userpassword: "secret"
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was updated: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.uid ?= config.username
      delete config.username
      if config.attributes
        config.attributes.mail = [config.attributes.mail] if typeof config.attributes.mail is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'uid':
            type: 'string'
            description: '''
            Name of the user to add or modify, same as the `username`.
            '''
          'username':
            type: 'string'
            description: '''
            Name of the user to add or modify, alias of `uid`.
            '''
          'attributes':
            type: 'object'
            properties:
              'givenname': type: 'string' # Firstname
              'sn': type: 'string' # Lastname
              'mail': type: 'array', minItems: 1, uniqueItems: true, items: type: 'string'
              'userpassword': type: 'string'
            description: '''
            Attributes associated with the user to add or modify.
            '''
          'force_userpassword':
            type: 'boolean'
            description: '''
            Force the password to be re-initialized on user update.
            '''
          'connection':
            type: 'object'
            $ref: 'module://@nikitajs/network/lib/http#/definitions/config'
            required: ['principal', 'password']
        required: ['attributes', 'connection', 'uid']

## Handler

    handler = ({config}) ->
      config.connection.http_headers['Referer'] ?= config.connection.referer or config.connection.url
      {$status} = await @ipa.user.exists
        connection: config.connection
        uid: config.uid
      exists = $status
      $status = true
      config.attributes.userpassword = undefined if exists and not config.force_userpassword
      {data} = await @network.http config.connection,
        negotiate: true
        method: 'POST'
        data:
          method: unless exists then 'user_add/1' else 'user_mod/1'
          params: [[config.uid], config.attributes]
          id: 0
      if data?.error
        if data.error.code isnt 4202 # no modifications to be performed
          error = Error data.error.message
          error.code = data.error.code
          throw error
        $status = false
      $status: $status

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
