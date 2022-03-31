
# `nikita.lxc.exec`

Execute command in containers.

## Example

```js
const {$status, stdout, stderr} = await nikita.lxc.exec({
  container: "my-container",
  command: "whoami"
})
console.info(`Command was executed: ${$status}`)
console.info(stdout)
```

## Todo

* Support `env` option

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'command':
            type: 'string'
            description: '''
            The command to execute.
            '''
          'cwd':
            type: 'string'
            description: '''
            Directory to run the command in (default /root).
            '''
          'env':
            type: 'object'
            default: {}
            description: '''
            Environment variable to set (e.g. HOME=/home/foo).
            '''
          'shell':
            type: 'string'
            default: 'sh'
            description: '''
            The shell in which to execute commands, for example `sh`, `bash` or
            `zsh`.
            '''
          'trim':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/trim'
          'trap':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/trap'
          'user':
            type: 'integer'
            description: '''
            User ID to run the command as (default 0).
            '''
        required: ['container', 'command']

## Handler

    handler =  ({config}) ->
      opt = [
        "--user #{config.user}" if config.user
        "--cwd #{utils.string.escapeshellarg config.cwd}" if config.cwd
        ...('--env ' + utils.string.escapeshellarg "#{k}=#{v}" for k, v of config.env)
      ].join ' '
      # Note, `trap` and `env` apply to `lxc exec` and not to `execute`
      config.trap = undefined
      config.env = undefined
      await @execute config,
        command: [
          "cat <<'NIKITALXDEXEC' | lxc exec #{opt} #{config.container} -- #{config.shell}"
          'set -e' if config.trap
          config.command
          'NIKITALXDEXEC'
        ].join '\n'

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require './utils'
