
# `nikita.lxc.config.device`

Create a device or update its configuration.

## Output

* `$status`
  True if the device was created or the configuraion updated.

## Example

```js
const {$status} = await nikita.lxc.config.device({
  container: 'container1',
  device: 'root',
  type: 'disk',
  properties: {
    'pool': 'system',
    'size': '10GB'
  }
})
console.info(`Disk was created: ${$status}`)
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
          'properties':
            type: 'object'
            patternProperties: '': type: ['string', 'boolean', 'number']
            description: '''
            One or multiple keys to set depending on the type.
            '''
          'type':
            type: 'string'
            description: '''
            Type of device, see [the list of device
            types](https://lxc.readthedocs.io/en/latest/instances/#device-types).
            '''
        oneOf: [
          { $ref: '#/definitions/disk' }
          { $ref: '#/definitions/infiniband' }
          { $ref: '#/definitions/gpu' }
          { $ref: '#/definitions/nic' }
          { $ref: '#/definitions/none' }
          { $ref: '#/definitions/proxy' }
          { $ref: '#/definitions/tpm' }
          { $ref: '#/definitions/unix-block' }
          { $ref: '#/definitions/unix-char' }
          { $ref: '#/definitions/unix-hotplug' }
          { $ref: '#/definitions/usb' }
        ]
        required: ['container', 'device', 'properties', 'type']
      'disk':
        type: 'object'
        properties:
          'properties':
            type: 'object'
            properties:
              'path':
                type: 'string'
                description: '''
                Path inside the instance where the disk will be mounted (only
                for containers).
                '''
              'source':
                type: 'string'
                description: '''
                Path on the host, either to a file/directory or to a block
                device.
                '''
            required: ['path', 'source']
          'type':
            const: 'disk'
      'infiniband':
        type: 'object'
        properties:
          'properties':
            type: 'object'
            properties:
              'nictype':
                type: 'string'
                enum: ['physical', 'sriov']
                description: '''
                The device type, one of "physical", or "sriov".
                '''
              'parent':
                type: 'string'
                description: '''
                The name of the host device or bridge.
                '''
            required: ['nictype', 'parent']
          'type':
            const: 'infiniband'
      'gpu':
        type: 'object'
        properties:
          'type':
            const: 'gpu'
      'nic':
        type: 'object'
        properties:
          'properties':
            type: 'object'
            properties:
              'nictype':
                type: 'string'
                enum: ['physical', 'bridged', 'macvlan', 'p2p', 'sriov']
                description: '''
                LXD supports different kind of [network
                devices](https://lxc.readthedocs.io/en/stable-3.0/containers/#type-nic)
                and each type of network interface types have different
                additional properties.
                '''
            oneOf: [
              { $ref: '#/definitions/nic_physical' }
              { $ref: '#/definitions/nic_bridged' }
              { $ref: '#/definitions/nic_ipvlan' }
              { $ref: '#/definitions/nic_macvlan' }
              { $ref: '#/definitions/nic_p2p' }
              { $ref: '#/definitions/nic_routed' }
              { $ref: '#/definitions/nic_sriov' }
            ]
          'type':
            const: 'nic'
      'nic_physical':
        type: 'object'
        properties:
          'nictype':
            const: 'physical'
      'nic_bridged':
        type: 'object'
        properties:
          'nictype':
            const: 'bridged'
          'ipv4.address':
            type: 'string'
            description: '''
            An IPv4 address to assign to the instance through DHCP.
            '''
      'nic_ipvlan':
        type: 'object'
        properties:
          'nictype':
            const: 'ipvlan'
          'ipv4.address':
            type: 'string'
            description: '''
            Comma delimited list of IPv4 static addresses to add to the
            instance. In l2 mode these can be specified as CIDR values or
            singular addresses (if singular a subnet of /24 is used).
            '''
      'nic_macvlan':
        type: 'object'
        properties:
          'nictype':
            const: 'macvlan'
      'nic_p2p':
        type: 'object'
        properties:
          'nictype':
            const: 'p2p'
      'nic_routed':
        type: 'object'
        properties:
          'nictype':
            const: 'routed'
          'ipv4.address':
            type: 'string'
            description: '''
             	Comma delimited list of IPv4 static addresses to add to the
             	instance.
            '''
      'nic_sriov':
        type: 'object'
        properties:
          'nictype':
            const: 'sriov'
      'none':
        type: 'object'
        properties:
          'type':
            const: 'none'
      'proxy':
        type: 'object'
        properties:
          'properties':
            type: 'object'
            properties:
              'connect':
                type: 'string'
                description: '''
                The address and port to bind and listen
                (<type>:<addr>:<port>[-<port>][,<port>])
                '''
              'parent':
                type: 'string'
                description: '''
                The address and port to connect to
                (<type>:<addr>:<port>[-<port>][,<port>])
                '''
            required: ['connect', 'listen']
          'type':
            const: 'proxy'
      'tpm':
        type: 'object'
        properties:
          'type':
            const: 'tpm'
      'unix-block':
        type: 'object'
        properties:
          'type':
            const: 'unix-block'
      'unix-char':
        type: 'object'
        properties:
          'type':
            const: 'unix-char'
      'unix-hotplug':
        type: 'object'
        properties:
          'properties':
            type: 'object'
            properties:
              'path':
                type: 'string'
                description: '''
                Path inside the instance (only for containers).
                '''
            required: ['path']
          'type':
            const: 'unix-hotplug'
      'usb':
        type: 'object'
        properties:
          'type':
            const: 'usb'

## Handler

    handler = ({config}) ->
      # Normalize config
      for k, v of config.properties
        continue if typeof v is 'string'
        config.properties[k] = v.toString()
      {properties} = await @lxc.config.device.show
        container: config.container
        device: config.device
      try
        unless properties
          # Device not registered, we need to use `add`
          {$status} = await @execute
            command: [
              'lxc', 'config', 'device', 'add',
              config.container
              config.device
              config.type
              ...(
                "#{key}='#{value.replace '\'', '\\\''}'" for key, value of config.properties
              )
            ].join ' '
        else
          # Device not registered, we need to use `set`
          changes = diff properties, config.properties
          {$status} = await @execute (
            command: [
              'lxc', 'config', 'device', 'set'
              config.container
              config.device
              key, "'#{value.replace '\'', '\\\''}'"
            ].join ' '
          ) for key, value of changes
        $status: $status
      catch err
        utils.stderr_to_error_message err, err.stderr
        throw err

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    diff = require 'object-diff'
    utils = require '../../utils'
