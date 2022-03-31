
# `nikita.lxc.delete`

Delete a Linux Container using lxc.

## Example

```js
const {$status} = await nikita.lxc.delete({
  container: "myubuntu"
})
console.info(`Container was deleted: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'force':
            type: 'boolean'
            default: false
            description: '''
            If true, the container will be deleted even if running.
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      await @execute
        command: """
        lxc info #{config.container} > /dev/null || exit 42
        #{[
          'lxc',
          'delete',
          config.container
          "--force" if config.force
        ].join ' '}
        """
        code_skipped: 42

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'container'
        definitions: definitions
