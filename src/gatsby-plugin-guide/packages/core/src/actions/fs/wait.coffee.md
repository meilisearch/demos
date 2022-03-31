
# `nikita.fs.wait`

Wait for a file or directory to exists. Status will be
set to "false" if the file already existed, considering that no
change had occured. Otherwise it will be set to "true".

## Example

```js
const {$status} = await nikita.fs.wait({
  target: '/path/to/file_or_directory'
})
console.info(`File was created: ${$status}`)
```

## Hooks

    on_action =
      after: '@nikitajs/core/src/plugins/metadata/argument_to_config'
      handler: ({config}) ->
        config.target = [config.target] if typeof config.target is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'target':
            type: 'array'
            items: type: 'string'
            description: '''
            Paths to the files and directories.
            '''
          'interval':
            type: 'integer'
            default: 2000
            description: '''
            Time interval between which we should wait before re-executing the
            check, default to 2s.
            '''
        required: ['target']

## Handler

    handler = ({config}, callback) ->
      status = false
      # Validate parameters
      for target in config.target
        {exists} = await @fs.base.exists target
        continue if exists
        await @wait config.interval
        while true
          {exists} = await @fs.base.exists target
          break if exists
          status = true
          @log message: "Wait for file to be created", level: 'INFO'
          await @wait config.interval
      status

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'target'
        definitions: definitions
