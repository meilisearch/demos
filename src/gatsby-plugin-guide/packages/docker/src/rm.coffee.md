
# `nikita.docker.rm`

Remove one or more containers. Containers need to be stopped to be deleted unless
force options is set.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was removed.

## Example Code

```js
const {$status} = await nikita.docker.rm({
  container: 'toto'
})
console.info(`Container was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            type: 'string'
            description: '''
            Name/ID of the container.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'link':
            type: 'boolean'
            description: '''
            Remove the specified link.
            '''
          'volumes':
            type: 'boolean'
            description: '''
            Remove the volumes associated with the container.
            '''
          'force':
            type: 'boolean'
            description: '''
            Force the removal of a running container (uses SIGKILL).
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      {$status: exists, data: running} = await @docker.tools.execute
        $templated: false
        command: """
        inspect #{config.container} --format '{{ json .State.Running }}'
        """
        code_skipped: 1
        format: 'json'
      return false unless exists
      throw Error 'Container must be stopped to be removed without force' if running and not config.force
      await @docker.tools.execute
        command: [
          'rm'
          ...( ['link', 'volumes', 'force']
            .filter (opt) -> config[opt]
            .map (opt) -> "-#{opt.charAt 0}"
          )
          config.container
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions
