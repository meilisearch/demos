
# `nikita.lxc.start`

Start containers.

## Output

* `$status`
  Was the container started or already running.

## Example

```js
const {$status} = await nikita.lxc.start({
  container: "my_container"
})
console.info(`Container was started: ${$status}`)
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
      command_init = [
        'lxc', 'start', config.container
      ].join ' '
      # Execution
      await @execute
        command: """
        lxc list -c ns --format csv | grep '#{config.container},RUNNING' && exit 42
        #{command_init}
        """
        code_skipped: 42

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
