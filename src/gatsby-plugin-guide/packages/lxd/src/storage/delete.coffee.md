
# `nikita.lxc.storage.delete`

Delete an existing lxd storage.

## Output

* `$status`
  True if the object was deleted

## Example

```js
const {$status} = await nikita.lxc.storage.delete({
  name: 'system'
})
console.info(`Storage was deleted: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'string'
            description: '''
            The storage name to delete.
            '''
        required: ['name']

## Handler

    handler = ({config}) ->
      command_delete = [
        'lxc'
        'storage'
        'delete'
         config.name
      ].join ' '
      #Execute
      await @execute
        command: """
        lxc storage list | grep #{config.name} || exit 42
        #{command_delete}
        """
        code_skipped: 42

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
