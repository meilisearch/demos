
# `nikita.lxc.file.exists`

Check if the file exists in a container.

## Example

```js
const {$status} = await nikita.lxc.file.exists({
  container: 'my_container',
  target: '/root/a_file'
})
console.info(`File exists: ${$status}`)
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'target':
            type: 'string'
            description: '''
            File destination in the form of "<path>".
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      {$status} = await @execute
        command: """
        lxc exec #{config.container} -- stat #{config.target}
        """
        code_skipped: 1
      exists: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
