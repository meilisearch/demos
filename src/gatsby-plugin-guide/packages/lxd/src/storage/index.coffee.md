
# `nikita.lxc.storage`

Create a storage or update a storage configuration.

## Output

* `$status`
  Was the storage created or updated

## Example

```js
const {$status} = await nikita.lxc.storage({
  name: "system",
  driver: "zfs",
  properties: {
    source: "syspool/lxd"
  }
})
console.info(`Storage was created or config updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'string'
            description: '''
            The storage name to create or update.
            '''
          'driver':
            type: 'string'
            enum: ["btrfs", "ceph", "cephfs", "dir", "lvm", "zfs"]
            description: '''
            The underlying driver name. Can be btrfs, ceph, cephfs, dir, lvm, zfs.
            '''
          'properties':
            type: 'object',
            patternProperties: '': type: ['string', 'boolean', 'number']
            description: '''
            The configuration to use to configure this storage, depends on the
            driver. See [available
            fields](https://lxc.readthedocs.io/en/latest/storage/).
            '''
        required: ['name', 'driver']

## Handler

    handler = ({config}) ->
      # Normalize config
      for k, v of config.properties
        continue if typeof v is 'string'
        config.properties[k] = v.toString()
      # Check if exists
      {stdout, code} = await @execute
        command: """
        lxc storage show #{config.name} && exit 42
        #{['lxc', 'storage', 'create'
          config.name
          config.driver
          ...(
            "#{key}='#{value.replace '\'', '\\\''}'" for key, value of config.properties
          )
        ].join ' '}
        """
        code_skipped: 42
      return unless code is 42
      # Storage already exists, find the changes
      return unless config?.properties
      {config: currentProperties} = yaml.load stdout
      changes = diff currentProperties, config.properties
      # if changes is empty status is false because no command were executed
      {$status} = await @execute (
        command: [
          'lxc', 'storage', 'set'
          config.name
          key, "'#{value.replace '\'', '\\\''}'"
        ].join ' '
      ) for key, value of changes
      $status: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    yaml = require 'js-yaml'
    diff = require 'object-diff'
