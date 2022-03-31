
# `nikita.service.stop`

Stop a service.
Note, does not throw an error if service is not installed.

## Output

* `$status`   
  Indicates if the service was stopped ("true") or if it was already stopped 
  ("false").

## Example

```js
const {$status} = await nikita.service.stop([{
  name: 'gmetad'
})
console.info(`Service was stopped: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/name'
        required: ['name']

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Stop service #{config.name}", level: 'INFO'
      try
        {$status} = await @execute
          command: """
          ls \
            /lib/systemd/system/*.service \
            /etc/systemd/system/*.service \
            /etc/rc.d/* \
            /etc/init.d/* \
            2>/dev/null \
          | grep -w "#{config.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status #{config.name} || exit 3
            systemctl stop #{config.name}
          elif command -v service >/dev/null 2>&1; then
            service #{config.name} status || exit 3
            service #{config.name} stop
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
          code_skipped: 3
          # arch_chroot: config.arch_chroot
          # arch_chroot_rootdir: config.arch_chroot_rootdir
        log message: "Service is stopped", level: 'INFO' if $status
        log message: "Service already stopped", level: 'WARN' if not $status
      catch err
        throw Error "Unsupported Loader" if err.exit_code is 2

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
