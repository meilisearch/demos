
# `nikita.docker.rmi`

Remove images. All container using image should be stopped to delete it unless
force options is set.

## Output

* `err`   
  Error object if any.
* `status`   
  True if image was removed.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cwd':
            type: 'string'
            description: '''
            Change the build working directory.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'image':
            type: 'string'
            description: '''
            Name of the Docker image present in the registry.
            '''
          'no_prune':
            type: 'boolean'
            description: '''
            Do not delete untagged parents.
            '''
          'tag':
            type: 'string'
            description: '''
            Tag of the Docker image, default to latest.
            '''
        required: ['image']

## Handler

    handler = ({config}) ->
      await @docker.tools.execute
        command: [
          'images'
          "| grep '#{config.image} '"
          "| grep ' #{config.tag} '" if config.tag?
        ].join ' '
        code_skipped: [1]
      await @docker.tools.execute
        $if: ({parent}) ->
          parent.parent.tools.status -1
        command: [
          'rmi'
          (
            ['force', 'no_prune']
            .filter (opt) -> config[opt]?
            .map (opt) -> " --#{opt.replace '_', '-'}"
          )
           " #{config.image}"
           ":#{config.tag}" if config.tag?
        ].join ''

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'image'
        global: 'docker'
        definitions: definitions
