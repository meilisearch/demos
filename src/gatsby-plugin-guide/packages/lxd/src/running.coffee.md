
# `nikita.lxc.running`

Check if container is running.

## Output

* `$status`
  Was the container started or already running.

## Example

```js
const {$status} = await nikita.lxc.running({
  container: "my_container"
})
console.info(`Container is running: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
        required: ['container']

## Handler

    handler = ({config}) ->
      await @execute
        command: """
        lxc list -c ns --format csv | grep '#{config.container},RUNNING' || exit 42
        """
        code_skipped: 42

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
