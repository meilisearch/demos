
# `nikita.docker.run`

Run Docker Containers

## Output

* `err`   
  Error object if any.
* `$status`   
  True unless contaianer was already running.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.run({
  name: 'myContainer'
  image: 'test-image'
  env: ["FOO=bar",]
  entrypoint: '/bin/true'
})
console.info(`Container was run: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      # throw Error 'Property "container" no longer exists' if config.container
      # config.name = config.container if not config.name? and config.container?
      config.name ?= config.container
      config.expose = parseInt config.expose if typeof config.expose is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'add_host':
            type: 'array'
            items: type: 'string'
            description: '''
            Add a custom host-to-IP mapping (host:ip) in the form of `host:ip`.
            '''
          'blkio_weight':
            type: 'integer'
            description: '''
            Block IO (relative weight), between 10 and 1000.
            '''
          'cap_add':
            type: 'array'
            items: type: 'string'
            description: '''
            Add Linux Capabilities.
            '''
          'cap_drop':
            type: 'array'
            items: type: 'string'
            description: '''
            Drop Linux Capabilities.
            '''
          'cgroup_parent':
            type: 'string'
            description: '''
            Optional parent cgroup for the container.
            '''
          'cid_file':
            type: 'string'
            description: '''
            Write the container ID to the file.
            '''
          'container':
            type: 'string'
            description: '''
            Alias of name.
            '''
          'cpuset_cpus':
            type: 'string'
            description: '''
            CPUs in which to allow execution (ex: 0-3 0,1 ...).
            '''
          'cwd':
            type: 'string'
            description: '''
            Working directory of container.
            '''
          'detach':
            type: 'boolean'
            description: '''
            if true, run container in background.
            '''
          'device':
            type: 'array'
            items: type: 'string'
            description: '''
            Send host device(s) to container.
            '''
          'dns':
            type: 'array'
            items: type: 'string'
            description: '''
            Set custom DNS server(s).
            '''
          'dns_search':
            type: 'array'
            items: type: 'string'
            description: '''
            Set custom DNS search domain(s).
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'entrypoint':
            type: 'string'
            description: '''
            Overwrite the default ENTRYPOINT of the image, equivalent to
            `--entrypoint docker parameter`
            '''
          'env':
            type: 'array'
            items: type: 'string'
            description: '''
            Environment variables for the container in the form of `VAR=value`.
            '''
          'env_file':
            type: 'array'
            items: type: 'string'
            description: '''
            Read in a file of environment variables.
            '''
          'expose':
            type: 'array'
            items: type: 'string'
            description: '''
            Export port(s).
            '''
          'hostname':
            type: 'string'
            description: '''
            Hostname in the docker container.
            '''
          'image':
            type: 'string'
            description: '''
            Name/ID of base image.
            '''
          'ipc':
            type: 'string'
            description: '''
            IPC namespace to use.
            '''
          'label':
            type: 'array'
            items: type: 'string'
            description: '''
            Set meta data on a container.
            '''
          'label_file':
            type: 'string'
            description: '''
            Path to read in a line delimited file of labels.
            '''
          'link':
            type: 'array'
            items: type: 'string'
            description: '''
            Link to other container(s) in the form of a container name or a
            container ID.
            '''
          'name':
            type: 'string'
            description: '''
            Assign a name to the container to run.
            '''
          'net':
            type: 'string'
            description: '''
            Set the Network mode for the container.
            '''
          'port':
            type: 'array'
            items: type: 'string'
            description: '''
            Port mapping in the form of `int:int`.
            '''
          'pid':
            type: 'string'
            description: '''
            PID namespace to use.
            '''
          'publish_all':
            type: 'boolean'
            description: '''
            Publish all exposed ports to random ports.
            '''
          'rm':
            type: 'boolean'
            default: true
            description: '''
            Delete the container when it ends. True by default.
            '''
          'ulimit':
            type: 'array'
            items: type: ['integer', 'string']
            description: '''
            Ulimit options.
            '''
          'volume':
            type: 'array'
            items: type: 'string'
            description: '''
            Volume mapping, in the form of `path:path`.
            '''
          'volumes_from':
            type: 'array'
            items: type: 'string'
            description: '''
            Mount volumes from the specified container(s).
            '''
        required: ['image']

## Handler

    handler = ({config, tools: {log}}) ->
      # Validate parameters
      log message: "Should specify a container name if rm is false", level: 'WARN' unless config.name? or config.rm
      # Construct exec command
      command = 'run'
      # Classic config
      for opt, flag of { name: '--name', hostname: '-h', cpu_shares: '-c',
      cgroup_parent: '--cgroup-parent', cid_file: '--cidfile', blkio_weight: '--blkio-weight',
      cpuset_cpus: '--cpuset-cpus', entrypoint: '--entrypoint', ipc: '--ipc',
      log_driver: '--log-driver', memory: '-m', mac_address: '--mac-address',
      memory_swap: '--memory-swap', net: '--net', pid: '--pid', cwd: '-w'}
        command += " #{flag} #{config[opt]}" if config[opt]?
      command += ' -d' if config.detach # else ' -t'
      # Flag config
      for opt, flag of { rm: '--rm', publish_all: '-P', privileged: '--privileged', read_only: '--read-only' }
        command += " #{flag}" if config[opt]
      # Arrays config
      for opt, flag of { port:'-p', volume: '-v', device: '--device', label: '-l',
      label_file: '--label-file', expose: '--expose', env: '-e', env_file: '--env-file',
      dns: '--dns', dns_search: '--dns-search', volumes_from: '--volumes-from',
      cap_add: '--cap-add', cap_drop: '--cap-drop', ulimit: '--ulimit', add_host: '--add-host' }
        if config[opt]?
          if typeof config[opt] is 'string' or typeof config[opt] is 'number'
            command += " #{flag} #{config[opt]}"
          else if Array.isArray config[opt]
            for p in config[opt]
              if typeof p in ['string', 'number']
                command += " #{flag} #{p}"
              else callback Error "Invalid parameter, '#{opt}' array should only contains string or number"
          else callback Error "Invalid parameter, '#{opt}' should be string, number or array"
      command += " #{config.image}"
      command += " #{config.command}" if config.command
      # need to delete the command config or it will be used in docker.exec
      # delete config.command
      {$status} = await @docker.tools.execute
        $if: config.name?
        $shy: true
        command: "ps -a | egrep ' #{config.name}$'"
        code_skipped: 1
      log message: "Container already running. Skipping", level: 'INFO' if $status
      result = await @docker.tools.execute
        $if: -> not config.name? or $status is false
        command: command
      log message: "Container now running", level: 'WARN' if result.$status
      result

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'docker'
        definitions: definitions
