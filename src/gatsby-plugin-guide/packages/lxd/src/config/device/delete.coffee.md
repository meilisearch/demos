
# `nikita.lxc.config.device.delete`

Delete a device from a container

## Output

* `$status`
  True if the device was removed False otherwise.

## Example

```js
const {$status} = await nikita.lxc.config.device.delete({
  container: 'container1',
  device: 'root'
})
console.info(`Device was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'device':
            type: 'string'
            description: '''
            Name of the device in LXD configuration, for example "eth0".
            '''
        required: ['container', 'device']

## Handler

    handler = ({config}) ->
      {properties} = await @lxc.config.device.show
        container: config.container
        device: config.device
      return $status: false unless properties
      {$status} = await @execute
        command: [
          'lxc', 'config', 'device', 'remove'
          config.container
          config.device
        ].join ' '
      $status: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
