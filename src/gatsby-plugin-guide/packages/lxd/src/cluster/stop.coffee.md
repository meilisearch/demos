
# `nikita.lxc.cluster.stop`

Stop a cluster of LXD instances.

## Example

```yaml
containers:
  nikita:
    image: "images:centos/7"
wait: true
prestop: path/to/action
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'containers':
            $ref: 'module://@nikitajs/lxd/src/cluster#/definitions/config/properties/containers'
          'wait':
            type: 'boolean'
            default: false
            description: """
            Wait for containers to be stopped before finishing action
            """
          'pre_stop':
            typeof: 'function'
        required: ['containers']

## Handler

    handler = ({config}) ->
      # Stop gracefully
      if !!config.pre_stop
        await @call config, config.pre_stop
      # Stop containers
      for containerName, containerConfig of config.containers
        await @lxc.stop
          $header: "Container #{containerName} : stop"
          container: containerName
          wait: config.wait
      {}

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
