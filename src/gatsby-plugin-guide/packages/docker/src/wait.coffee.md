
# `nikita.docker.wait`

Block until a container stops.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True unless container was already stopped.

## Example

```js
const {$status} = await nikita.docker.wait({
  container: 'toto'
})
console.info(`Did we really had to wait: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            type: 'string'
            description: '''
            Name/ID of the container.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
        required: ['container']

## Handler

    handler = ({config}) ->
      # Old implementation was `wait {container} | read r; return $r`
      await @docker.tools.execute "wait #{config.container}"

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
