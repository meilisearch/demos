
# `nikita.docker.restart`

Start stopped containers or restart (stop + starts) a started container.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True if container was restarted.  

## Example

```js
const {$status} = await nikita.docker.restart({
  container: 'toto'
})
console.info(`Container was started or restarted: ${$status}`)
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
          'timeout':
            type: 'integer'
            description: '''
            Seconds to wait for stop before killing it.
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      await @docker.tools.execute
        command: [
          'restart'
          "-t #{config.timeout}" if config.timeout?
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
