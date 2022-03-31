
# `nikita.docker.volume_create`

Create a volume.

## Output

* `err`   
  Error object if any.   
* `$status`   
  True is volume was created.

## Example

```js
const {$status} = await nikita.docker.volume_create({
  name: 'my_volume'
})
console.info(`Volume was created: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'driver':
            type: 'string'
            description: '''
            Specify volume driver name.
            '''
          'label':
            type: 'array'
            items: type: 'string'
            description: '''
            Set metadata for a volume.
            '''
          'name':
            type: 'string'
            description: '''
            Specify volume name.
            '''
          'opt':
            type: 'array'
            items: type: 'string'
            description: '''
            Set driver specific options.
            '''

## Handler

    handler = ({config}) ->
      # Normalize config
      config.label = [config.label] if typeof config.label is 'string'
      config.opt = [config.opt] if typeof config.opt is 'string'
      {$status} = await @docker.tools.execute
        $if: config.name
        $shy: true
        command: "volume inspect #{config.name}"
        code: 1
        code_skipped: 0
      await @docker.tools.execute
        $if: not config.name or $status
        command: [
          "volume create"
          "--driver #{config.driver}" if config.driver
          "--label #{config.label.join ','}" if config.label
          "--name #{config.name}" if config.name
          "--opt #{config.opt.join ','}" if config.opt
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
