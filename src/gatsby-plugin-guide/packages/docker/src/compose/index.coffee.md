
# `nikita.docker.compose`

Create and start containers according to a docker-compose.yml file
`nikita.docker.compose` is an alias to `nikita.docker.compose.up`

## Output

*   `err`   
    Error object if any.   
*   `executed`   
    if command was executed   
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.   
*   `stderr`   
    Stderr value(s) unless `stderr` option is provided.   

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            type: 'object'
            description: '''
            The content of the docker-compose.yml to write if not exist.
            '''
          'eof':
            type: 'boolean'
            default: true
            description: '''
            Inherited from nikita.file use when writing docker-compose.yml file.
            '''
          'backup':
            type: ['string', 'boolean']
            default: false
            description: '''
            Create a backup, append a provided string to the filename extension or
            a timestamp if value is not a string, only apply if the target file
            exists and is modified.
            '''
          'detached':
            type: 'boolean'
            default: true
            description: '''
            Run containers in detached mode.
            '''
          'force':
            type: 'boolean'
            default: false
            description: '''
            Force to re-create the containers if the config and image have not
            changed.
            '''
          'services':
            type: 'array'
            items: type: 'string'
            description: '''
            Specify specific services to create.
            '''
          'target':
            type: 'string'
            description: '''
            The docker-compose.yml absolute's file's path, required if no content
            is specified.
            '''

## Handler

    handler = ({config, tools: {find, log}}) ->
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Validate parameters
      throw Error 'Missing docker-compose content or target' if not config.target? and not config.content?
      if config.content and not config.target?
        config.target ?= "/tmp/nikita_docker_compose_#{Date.now()}/docker-compose.yml"
        clean_target = true
      config.recreate ?= false # TODO: move to schema
      config.services ?= []
      config.services = [config.services] if not Array.isArray config.services
      await @file.yaml
        $if: config.content?
        eof: config.eof
        backup: config.backup
        target: config.target
        content: config.content
      {$status, stdout} = await @docker.tools.execute
        $shy: true
        command: "--file #{config.target} ps -q | xargs docker #{utils.opts config} inspect"
        compose: true
        cwd: config.cwd
        uid: config.uid
        code_skipped: 123
        stdout_log: false
      unless $status
        $status = true
      else
        containers = JSON.parse stdout
        $status = containers.some (container) -> not container.State.Running
        log "Docker created, need start" if $status
      try
        await @docker.tools.execute
          $if: config.force or $status
          command: [
            "--file #{config.target} up"
            '-d' if config.detached
            '--force-recreate' if config.force
            ...config.services
          ].join ' '
          compose: true
          cwd: path.dirname config.target
          uid: config.uid
      finally
        await @fs.remove
          $if: clean_target
          target: config.target

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
    path = require 'path'
