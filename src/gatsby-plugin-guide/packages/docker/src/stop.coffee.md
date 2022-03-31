
# `nikita.docker.stop`

Stop a started container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless container was already stopped.

## Example

```js
const {$status} = await nikita.docker.stop({
  container: 'toto'
})
console.info(`Container was stopped: ${$status}`)
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
            Seconds to wait for stop before killing the container (Docker default
            is 10).
            '''
        required: ['container']

## Handler

    handler = ({config, tools: {log}}) ->
      # rm is false by default only if config.service is true
      {$status} = await @docker.tools.status config, $shy: true
      if $status
      then log message: "Stopping container #{config.container}", level: 'INFO', module: 'nikita/lib/docker/stop'
      else log message: "Container already stopped #{config.container} (Skipping)", level: 'INFO', module: 'nikita/lib/docker/stop'
      await @docker.tools.execute
        $if: $status
        command: [
          'stop'
          "-t #{config.timeout}" if config.timeout?
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
