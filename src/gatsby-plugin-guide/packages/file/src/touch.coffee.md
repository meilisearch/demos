
# `nikita.file.touch`

Create a empty file if it does not yet exists.

## Implementation details

Status will only be true if the file was created.

## Output

* `$status`   
  Value is "true" if file was created or modified.   

## Example

```js
const {$status} = await nikita.file.touch({
  target: '/tmp/a_file'
})
console.info(`File was touched: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'target':
            oneOf: [
              type: 'string'
            ,
              typeof: 'function'
            ]
            description: '''
            File path where to write file or a function that returns a valid file
            path.
            '''
          'uid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
        required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      {$status} = await @call ->
        log message: "Check if target exists \"#{config.target}\"", level: 'DEBUG'
        {exists} = await @fs.base.exists target: config.target
        log message: "Destination does not exists", level: 'INFO' if not exists
        !exists
      # if the file doesn't exist, create a new one
      if $status
        await @file
          content: ''
          target: config.target
          mode: config.mode
          uid: config.uid
          gid: config.gid
      # if the file exists, overwrite it using `touch` but don't update the status
      else
        # todo check uid/gid/mode
        await @execute
          $shy: true
          command: "touch #{config.target}"
      {}

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        definitions: definitions
