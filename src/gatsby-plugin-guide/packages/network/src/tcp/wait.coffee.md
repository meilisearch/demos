
# `nikita.network.tcp.wait`

Check if one or multiple hosts listen one or multiple ports periodically and
continue once all the connections succeed. Status will be set to "false" if the
user connections succeed right away, considering that no change had occured.
Otherwise it will be set to "true".   

## Return

Status is set to "true" if the first connection attempt was a failure and the 
connection finaly succeeded.

## TODO

The `server` configuration property shall be renamed `address`.

## Examples

Wait for two domains on the same port.

```js
const {$status} = await nikita.network.tcp.wait({
  hosts: [ '1.domain.com', '2.domain.com' ],
  port: 80
})
console.info(`Servers listening on port 80: ${$status}`)
```

Wait for one domain on two diffents ports.

```js
const {$status} = await nikita.network.tcp.wait({
  host: 'my.domain.com',
  ports: [80, 443]
})
console.info(`Servers listening on ports 80 and 443: ${$status}`)
```

Wait for two domains on diffents ports.

```js
const {$status} = await nikita.network.tcp.wait({
  servers: [
    {host: '1.domain.com', port: 80},
    {host: '2.domain.com', port: 443}
  ]
})
console.info(`Servers listening: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      if config.server
        if Array.isArray config.server
        then config.server = utils.array.flatten config.server
        else config.server = [config.server]
      extract_servers = (config) ->
        if typeof config is 'string'
          [host, port] = config.split ':'
          config = host: host, port: port
        return [] if not config.host or not config.port
        if config.host
          config.host = [config.host] unless Array.isArray config.host
        if config.port
          config.port = [config.port] unless Array.isArray config.port
        servers = []
        for host in config.host or []
          for port in config.port or []
            servers.push host: host, port: port
        servers
      srvs = extract_servers config
      if config.server
        srvs.push ...extract_servers(srv) for srv in config.server
      config.server = srvs
      config.server = utils.array.flatten config.server

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'host':
            type: 'array'
            items:
              type: 'string'
            description: '''
            One or multiple hosts, used to build or enrich the 'server' option.
            '''
          'interval':
            type: 'number'
            description: '''
            Time in millisecond between each connection attempt.
            '''
          'quorum':
            type: ['boolean', 'integer']
            description: '''
            Number of minimal successful connection, 50%+1 if "true".
            '''
          'port':
            type: 'array'
            items:
              type: 'integer'
            description: '''
            One or multiple ports, used to build or enrich the 'server' option.
            '''
          'randdir':
            type: 'string'
            description: '''
            Directory where to write temporary file used internally to store state
            information. It default to a temporary location.
            '''
          'server':
            oneOf: [
              type: 'string'
            ,
              type: 'object'
              properties:
                host: $ref: '#/definitions/config/properties/host'
                port: $ref: '#/definitions/config/properties/port'
            ,
              type: 'array'
              items:
                oneOf: [
                  type: 'string'
                ,
                  type: 'object'
                  properties:
                    host: $ref: '#/definitions/config/properties/host'
                    port: $ref: '#/definitions/config/properties/port'
                ]
            ]
            description: '''
            One or multiple servers, string must be in the form of
            "{host}:{port}", object must have the properties "host" and "port".
            '''
          'timeout':
            type: 'integer'
            description: '''
            Maximum time in millisecond to wait until this function is considered
            to have failed.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      unless config.server?.length
        log message: "No connection to wait for", level: 'WARN'
        return
      # Validate servers
      config.interval ?= 2000 # 2s
      config.interval = Math.round config.interval / 1000
      quorum_target = config.quorum
      if quorum_target and quorum_target is true
        quorum_target = Math.ceil config.server.length / 2
      else unless quorum_target?
        quorum_target = config.server.length
      # Note, the option is not tested and doesnt seem to work from a manual test
      config.timeout = 0 unless config.timeout > 0
      config.timeout = Math.round config.timeout / 1000
      await @execute
        bash: true
        command: """
        function compute_md5 {
          echo $1 | openssl md5 | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
        }
        addresses=( #{config.server.map((server) -> "'" + server.host + "':'" + server.port + "'").join(' ')} )
        timeout=#{config.timeout or ''}
        md5=`compute_md5 ${addresses[@]}`
        randdir="#{config.randdir or ''}"
        if [ -z $randir ]; then
          if [ -w /dev/shm ]; then
            randdir="/dev/shm/$md5"
          else
            randdir="/tmp/$md5"
          fi
        fi
        quorum_target=#{quorum_target}
        echo "[INFO] randdir is: $randdir"
        mkdir -p $randdir
        echo 3 > $randdir/signal
        echo '' > $randdir/quorum
        function remove_randdir {
          for address in "${addresses[@]}" ; do
            host="${address%%:*}"
            port="${address##*:}"
            rm -f $randdir/`compute_md5 $host:$port`
          done
        }
        function check_quorum {
          quorum_current=`wc -l < $randdir/quorum`
          echo "[DEBUG] Check if $quorum_current gt $quorum_target"
          if [ $quorum_current -ge $quorum_target ]; then
            echo '[INFO] Quorum is reached'
            remove_randdir
          fi
        }
        function check_timeout {
          local timeout=$1
          local randfile4conn=$2
          sleep $timeout
          echo "[WARN] Reach timeout"
          rm -f $randfile4conn
        }
        function wait_connection {
          local host=$1
          local port=$2
          local randfile4conn=$3
          local count=0
          echo "[DEBUG] Start wait for $host:$port"
          isopen="echo > '/dev/tcp/$host/$port'"
          touch "$randfile4conn"
          while [[ -f "$randfile4conn" ]] && ! `bash -c "$isopen" 2>/dev/null`; do
            ((count++))
            echo "[DEBUG] Connection failed to $host:$port on attempt $count" >&2
            sleep #{config.interval}
          done
          if [[ -f "$randfile4conn" ]]; then
            echo "[DEBUG] Connection ready to $host:$port"
          fi
          echo $host:$port >> $randdir/quorum
          check_quorum
          if [ "$count" -gt "0" ]; then
            echo "[WARN] Status is now active, count is $count"
            echo 0 > $randdir/signal
          fi
        }
        if [ ! -z "$timeout" ]; then
          host="${address%%:*}"
          port="${address##*:}"
          check_timeout $timeout `compute_md5 $host:$port` &
        fi
        for address in "${addresses[@]}" ; do
          host="${address%%:*}"
          port="${address##*:}"
          randfile4conn=$randdir/`compute_md5 $host:$port`
          wait_connection $host $port $randfile4conn &
        done
        wait
        # Clean up
        signal=`cat $randdir/signal`
        remove_randdir
        echo "[INFO] Exit code is $signal"
        exit $signal
        """
        code_skipped: 3
        stdin_log: false

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
