
# `nikita.docker.volume_rm`

Remove a volume.

## Output

* `err`   
  Error object if any.
* `$status`   
  True is volume was removed.

## Example

```js
const {$status} = await nikita.docker.volume_rm({
  name: 'my_volume'
})
console.info(`Volume was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'name':
            type: 'string'
            description: '''
            Specify volume name.
            '''

## Handler

    handler = ({config}) ->
      # Validation
      throw Error "Missing required option name" unless config.name
      await @docker.tools.execute
        command: "volume rm #{config.name}"
        code: 0
        code_skipped: 1

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
