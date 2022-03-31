
# `nikita.docker.unpause`

Unpause all processes within a container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was unpaused.

## Example

```js
const {$status} = await nikita.docker.unpause({
  container: 'toto'
})
console.info(`Container was unpaused: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            type: 'string'
            description: '''
            Name/ID of the container
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
        required: ['container']

## Handler

    handler = ({config}) ->
      @docker.tools.execute
        command: "unpause #{config.container}"

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
