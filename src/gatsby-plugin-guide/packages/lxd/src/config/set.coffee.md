
# `nikita.lxc.config.set`

Set container or server configuration keys.

## Set a configuration key

```js
const {$status} = await nikita.lxc.config.set({
  name: "my_container",
  properties: {
    'boot.autostart.priority': 100
  }
})
console.info(`Property was set: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'properties':
            type: 'object'
            patternProperties:
              '': type: ['string', 'boolean', 'number']
            description: '''
            One or multiple keys to set.
            '''
        required: ['container', 'properties']

## Handler

    handler = ({config}) ->
      # Normalize config
      for k, v of config.properties
        continue if typeof v is 'string'
        config.properties[k] = v.toString()
      keys = {}
      {stdout} = await @execute
        $shy: true
        command: """
        #{[
          'lxc', 'config', 'show'
          config.container
        ].join ' '}
        """
        code_skipped: 42
      {config: properties} = yaml.load stdout
      changes = diff properties, merge properties, config.properties
      # if changes is empty status is false because no command were executed
      # Note, it doesnt seem possible to set multiple keys in one command
      {$status} = await @execute (
        command: [
          'lxc', 'config', 'set'
          config.container
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

    {merge} = require 'mixme'
    yaml = require 'js-yaml'
    diff = require 'object-diff'
