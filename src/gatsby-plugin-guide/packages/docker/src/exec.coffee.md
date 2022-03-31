
# `nikita.docker.exec`

Run a command in a running container

## Output

* `err`   
  Error object if any.   
* `$status`   
  True if command was executed in container.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Example

```js
const {$status} = await nikita.docker.exec({
  container: 'myContainer',
  command: '/bin/bash -c "echo toto"'
})
console.info(`Command was executed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'code_skipped':
            type: 'array', items: type: 'integer'
            description: '''
            The exit code(s) to skip.
            '''
          'container':
            type: 'string'
            description: '''
            Name/ID of the container
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'gid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/base/chown#/definitions/config/properties/uid'
          'service':
            type: 'boolean'
            default: false
            description: '''
            If true, run container as a service, else run as a command, true by
            default.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/base/chown#/definitions/config/properties/uid'
        required: ['container', 'command']

## Handler

    handler = ({config, tools: {log}}) ->
      config.service ?= false
      # Construct exec command
      command = 'exec'
      if config.uid?
        command += " -u #{config.uid}"
        command += ":#{config.gid}" if config.gid?
      else if config.gid?
        log message: 'config.gid ignored unless config.uid is provided', level: 'WARN'
      command += " #{config.container} #{config.command}"
      # delete config.command
      await @docker.tools.execute
        command: command
        code_skipped: config.code_skipped

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
