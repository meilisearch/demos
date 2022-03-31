
# `nikita.lxc.network`

Create a network or update a network configuration

## Output

* `$status`
  True if the network was created/updated

## Example

```js
const {$status} = await nikita.lxc.network({
  network: 'lxbr0'
  properties: {
    'ipv4.address': '172.89.0.0/24',
    'ipv6.address': 'none'
  }
})
console.info(`Network was created: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'network':
            type: 'string'
            description: '''
            The network name to create.
            '''
          'properties':
            type: 'object'
            patternProperties:
              'dns\\.domain':
                type: 'string'
                format: 'hostname'
                description: '''
                Domain to advertise to DHCP clients and use for DNS resolution.
                Note, single label domains like `nikita` are supported by LXD but
                are not valid. For exemple, FreeIPA will fail to Initialize. Use
                `nikita.local` instead.
                '''
              '.*': type: ['string', 'boolean', 'number']
            description: '''
            The network configuration, see [available
            fields](https://lxc.readthedocs.io/en/latest/networks/).
            '''
        required: ['network']

## Handler

    handler = ({config}) ->
      # Normalize config
      for k, v of config.properties
        continue if typeof v is 'string'
        config.properties[k] = v.toString()
      # Command if the network does not yet exist
      {stdout, code, $status} = await @execute
        # return code 5 indicates a version of lxc where 'network' command is not implemented
        command: """
        lxc network 2>/dev/null || exit 5
        lxc network show #{config.network} && exit 42
        #{[
          'lxc',
          'network',
          'create'
          config.network
          ...(
            "#{key}='#{value.replace '\'', '\\\''}'" for key, value of config.properties
          )
        ].join ' '}
        """
        code_skipped: [5, 42]
      throw Error "This version of lxc does not support the network command." if code is 5
      return $status: $status unless code is 42 # was created
      # Network already exists, find the changes
      return unless config?.properties
      current = yaml.load stdout
      changes = diff current.config, merge current.config, config.properties
      {$status} = await @execute (
        command: [
          'lxc', 'network', 'set'
          config.network
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
    {merge} = require 'mixme'
