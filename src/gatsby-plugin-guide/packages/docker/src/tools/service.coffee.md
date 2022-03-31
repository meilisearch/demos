
# `nikita.docker.tools.service`

Run a container in a service mode. This module is just a wrapper for
`docker.run`. It declares the same configuration with the exeception of the
properties `detach` and `rm` which respectively default to `true` and `false`.

Indeed, in a service mode, the container must be detached and NOT removed by default
after execution. 

## Schema definitions

    definitions =
      config:
        type: 'object'
        allOf: [
          properties:
            'detach':
              default: true
            'rm':
              default: false
        ,
          $ref: 'module://@nikitajs/docker/src/run'
        ]
        required: ['container', 'image']

## Handler

    handler = ({config, tools: {find, log}}) ->
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      # Normalization
      config.detach ?= true
      config.rm ?= false
      # Validation
      await @docker.run config

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
