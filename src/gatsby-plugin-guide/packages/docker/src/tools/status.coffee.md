
# `nikita.docker.tools.status`

Return true if container is running. This function is not native to docker. 

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container is running.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.tools.status({
  container: 'container1'
})
console.info(`Container is running: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            type: 'array'
            items: type: 'string'
            description: '''
            Name or Id of the container.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
        required: ['container']

## Handler

    handler = ({config, tools: {find, log}}) ->
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Construct exec command
      await @docker.tools.execute
        command: "ps | egrep ' #{config.container}$'"
        code_skipped: 1

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
