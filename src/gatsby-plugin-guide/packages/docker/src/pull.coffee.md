
# `nikita.docker.pull`

Pull an image or a repository from a registry.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was pulled.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.pull({
  image: 'postgresql'
})
console.info(`Image was pulled: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'all':
            type: 'boolean'
            default: false
            description: '''
            Pull all tagged images in the repository.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'image':
            type: 'string'
            description: '''
            Name of an image or a repository to pull. It can contain `tag`.
            '''
          'tag':
            type: 'string'
            description: '''
            Specific image tag within a repository to pull. Default to `latest`.
            '''

## Handler

    handler = ({config}) ->
      # Validate
      [name, tag] = config.image.split(':')
      config.image = name
      # it can be later changed to give a preference instead of error
      throw Error 'Tag must be specified either in the image or in the tag config' if tag and config.tag
      config.tag ?= tag or 'latest'
      # Check if exist
      {$status} = await @docker.tools.execute
        # avoid checking when all config is true,
        # because there is no native way to list all existing tags on the registry
        $unless: config.all
        command: [
          'images'
          "| grep '#{config.image}'"
          "| grep '#{config.tag}'"
        ].join ' '
        code_skipped: 1
      # Pull image
      await @docker.tools.execute
        $unless: $status
        command: [
          'pull'
          if config.all
          then "-a #{config.image}"
          else "#{config.image}:#{config.tag}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
