
# `nikita.docker.tools.execute`

Execute a docker command.

## Schema definitions

    definitions =
      config:
        type: 'object'
        allOf: [
          $ref: '#/definitions/docker'
        ,
          properties:
            'bash':
              type: ['boolean', 'string']
              description: '''
              Serialize the command into a file and execute it with bash.
              '''
            'command':
              oneOf: [
                type: 'string'
              ,
                typeof: 'function'
              ]
              description: '''
              String, Object or array; Command to execute. A value provided as a
              function is interpreted as an action and will be called by forwarding
              the config object. The result is the expected to be the command
              to execute.
              '''
            'cwd':
              type: 'string'
              description: '''
              Current working directory from where to execute the command.
              '''
            'code':
              type: 'array'
              default: [0]
              items:
                type: 'integer'
              description: '''
              Expected code(s) returned by the command, int or array of int, default
              to 0.
              '''
            'docker':
              $ref: '#/definitions/docker'
          ,
            $ref: 'module://@nikitajs/core/lib/actions/execute'
        ]
        required: ['command']
      # Note, we can't use additionalProperties properties with anyOf for now,
      # from the doc: "There are some proposals to address this in the next
      # version of the JSON schema specification."
      # additionalProperties: false
      'docker':
        type: 'object'
        description: '''
        Isolate all the parent configuration properties into a docker
        property, used when providing and cascading a docker configuration at
        a global scale.
        '''
        properties:
          'boot2docker':
            type: 'boolean'
            default: false
            description: '''
            Whether to use boot2docker or not.
            '''
          'compose':
            type: 'boolean'
            description: '''
            Use the `docker compose` command instead of `docker`.
            '''
          'machine':
            type: 'string'
            format: 'hostname'
            description: '''
            Name of the docker-machine, required if using docker-machine.
            '''
    # (
    #   schema.properties["#{property}"] =
    #     $ref: "module://@nikitajs/core/lib/actions/execute#/properties/#{property}"
    # ) for property in [
    #   'code_skipped', 'dry', 'env', 'format', 'gid', 'stdin_log',
    #   'stdout', 'stdout_return', 'stdout_log',
    #   'stderr', 'stderr_return', 'stderr_log',
    #   'sudo', 'target', 'trap', 'uid'
    # ]

## Handler

    handler = ({config, tools: {find}}) ->
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      opts = for option in utils[ unless config.compose then 'options' else 'compose_options' ]
        value = config[option]
        continue unless value?
        value = 'true' if value is true
        value = 'false' if value is false
        if option in ['tlsverify'] then  "--#{option}" else "--#{option}=#{value}"
      opts = opts.join ' '
      bin = if config.compose then 'bin_compose' else 'bin_docker'
      try
        await @execute config,
          command: """
          export SHELL=/bin/bash
          export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
          bin_boot2docker=$(command -v boot2docker)
          bin_docker=$(command -v docker)
          bin_machine=$(command -v docker-machine)
          bin_compose=$(command -v docker-compose)
          machine='#{config.machine or ''}'
          boot2docker='#{if config.boot2docker then '1' else ''}'
          docker=''
          if [[ $machine != '' ]] && [ $bin_machine ]; then
            if [ -z "#{config.machine or ''}" ]; then exit 5; fi
            if docker-machine status "${machine}" | egrep 'Stopped|Saved'; then
              docker-machine start "${machine}";
            fi
            eval "$(${bin_machine} env ${machine})"
          elif [[ $boot2docker != '1' ]] && [  $bin_boot2docker ]; then
            eval "$(${bin_boot2docker} shellinit)"
          fi
          $#{bin} #{opts} #{config.command}
          """
      catch err
        throw Error err.stderr.trim() if utils.string.lines(err.stderr.trim()).length is 1
        throw Error err.stderr.trim().replace 'Error response from daemon: ', '' if /^Error response from daemon/.test err.stderr

## Exports

    module.exports =
      handler: handler
      # hooks:
      #   on_action: require('@nikitajs/core/lib/actions/execute').hooks.on_action
      metadata:
        argument_to_config: 'command'
        definitions: definitions

## Dependencies

    utils = require '../utils'
