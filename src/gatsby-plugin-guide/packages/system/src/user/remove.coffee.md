
# `nikita.system.user.remove`

Create or modify a Unix user.

## Callback parameters

* `$status`   
  Value is "true" if user was created or modified.

## Example

```js
const {$status} = await nikita.system.user.remove({
  name: 'a_user'
})
console.log(`User removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          name:
            type: 'string'
            description: '''
            Name of the user to removed.
            '''
        required: ['name']

## Handler

    handler = ({config}) ->
      @execute
        command: "userdel #{config.name}"
        code_skipped: 6

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
      definitions: definitions
