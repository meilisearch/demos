
# `nikita.system.running`

Check if a process is running.

## Check if the pid is running

The example check if a pid match a running process.

```js
const {$status} = await nikita.system.running({
  pid: 1034,
})
console.info(`Is PID running: ${$status}`)
```

## Check if the pid stored in a file is running

The example read a file and check if the pid stored inside is currently running.
This pattern is used by YUM and APT to create lock files. The target file will
be removed if it stores a value not matching a running pid.

```js
const {$status} = await nikita.system.running({
  target: '/var/run/yum.pid'
})
console.info(`Is PID running: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.pid = parseInt config.pid, 10 if typeof config.pid is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'pid':
            type: 'integer'
            description: '''
            The PID of the process to inspect, required if `target` is not provided.
            '''
          'target':
            type: 'string'
            description: '''
            Path to the file storing the PID value, required if `pid` is not provided.
            '''
        anyOf: [
          required: ['pid']
        ,
          required: ['target']
        ]

## Handler

    handler = ({config, tools: {log}}) ->
      # Validate parameters
      throw Error 'Invalid Options: one of pid or target must be provided' unless config.pid? or config.target
      throw Error 'Invalid Options: either pid or target must be provided' if config.pid? and config.target
      if config.pid
        {code} = await @execute
          command: """
          kill -s 0 '#{config.pid}' >/dev/null 2>&1 || exit 42
          """
          code_skipped: 42
        log switch code
          when 0 then message: "PID #{config.pid} is running", level: 'INFO', module: 'nikita/lib/system/running'
          when 42 then message: "PID #{config.pid} is not running", level: 'INFO', module: 'nikita/lib/system/running'
        return running: true if code is 0
      if config.target
        {code, stdout} = await @execute
          command: """
          [ -f '#{config.target}' ] || exit 43
          pid=`cat '#{config.target}'`
          echo $pid
          if ! kill -s 0 "$pid" >/dev/null 2>&1; then
            rm '#{config.target}';
            exit 42;
          fi
          """
          code_skipped: [42, 43]
          stdout_trim: true
        log switch code
          when 0 then message: "PID #{stdout} is running", level: 'INFO', module: 'nikita/lib/system/running'
          when 42 then message: "PID #{stdout} is not running", level: 'INFO', module: 'nikita/lib/system/running'
          when 43 then message: "PID file #{config.target} does not exists", level: 'INFO', module: 'nikita/lib/system/running'
        return running: true if code is 0
      running: false

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        # raw_output: true
        definitions: definitions
