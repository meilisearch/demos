
# `nikita.lxc.network.delete`

Delete an existing lxd network.

## Output

* `$status`   
  True if the network was deleted.

## Example

```js
const {$status} = await nikita.lxc.network.delete({
  network: 'network0'
})
console.info(`Network was deleted: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'network':
            type: 'string'
            description: '''
            The network name to delete.
            '''
        required: ['network']

## Handler

    handler = ({config}) ->
      #Execute
      await @execute
        command: """
        lxc network list --format csv | grep #{config.network} || exit 42
        #{[
          'lxc'
          'network'
          'delete'
           config.network
        ].join ' '}
        """
        code_skipped: 42

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
