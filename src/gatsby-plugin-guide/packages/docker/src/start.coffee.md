
# `nikita.docker.start`

Start a container.

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless container was already started.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.start({
  container: 'toto',
  attach: true
})
console.info(`Container was started: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'attach':
            type: 'boolean'
            default: false
            description: '''
            Attach STDOUT/STDERR.
            '''
          'container':
            type: 'string'
            description: '''
            Name/ID of the container, required.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
        required: ['container']

## Handler

    handler = ({config, tools: {log}}) ->
      {$status} = await @docker.tools.status config, $shy: true
      if $status
      then log message: "Container already started #{config.container} (Skipping)", level: 'INFO', module: 'nikita/lib/docker/start'
      else log message: "Starting container #{config.container}", level: 'INFO', module: 'nikita/lib/docker/start'
      await @docker.tools.execute
        $unless: $status
        command: [
          'start'
          '-a' if config.attach
          "#{config.container}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
