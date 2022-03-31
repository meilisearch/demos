
# `nikita.fs.chmod`

Change the permissions of a file or directory.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file permissions was created or modified.   

## Example

```js
const {$status} = await nikita.fs.chmod({
  target: '~/my/project',
  mode: 0o755
})
console.info(`Permissions were modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'mode':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chmod#/definitions/config/properties/mode'
          'stats':
            typeof: 'object'
            description: '''
            Stat object of the target file. Short-circuit to avoid fetching the
            stat object associated with the target if one is already available.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the file which permission will change.
            '''
        required: ['mode']

## Handler

    handler = ({config, tools: {log}}) ->
      if config.stats
      then stats = config.stats
      else {stats} = await @fs.base.stat config.target
      # Detect changes
      if utils.mode.compare stats.mode, config.mode
        log message: "Identical permissions \"#{config.mode.toString 8}\" on \"#{config.target}\"", level: 'INFO'
        return false
      # Apply changes
      await @fs.base.chmod target: config.target, mode: config.mode
      log message: "Permissions changed from \"#{stats.mode.toString 8}\" to \"#{config.mode.toString 8}\" on \"#{config.target}\"", level: 'WARN'
      true

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        definitions: definitions

## Dependencies

    utils = require '../../utils'
