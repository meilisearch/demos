
# `nikita.db.query`

Make requests to a database.

## Hooks

    on_action = ({config}) ->
      config.engine = config.engine?.toLowerCase()

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin_username':
            type: 'string'
            description: '''
            The login of the database administrator. It should have the necessary
            permissions such as to  create accounts when using the
            `nikita.db.user` action.
            '''
          'admin_password':
            type: 'string'
            description: '''
            The password of the database administrator.
            '''
          'database':
            type: ['null', 'string'],
            description: '''
            The default database name, provide the value `null` if you want to
            ensore no default database is set.
            '''
          'grep':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Ensure the query output match a string or a regular expression
            '''
          'engine':
            type: 'string'
            enum: ['mariadb', 'mysql', 'postgresql']
            description: '''
            The engine type, can be MariaDB, MySQL or PostgreSQL. Values
            are converted to lower cases.
            '''
          'host':
            type: 'string'
            description: '''
            The hostname of the database.
            '''
          'port':
            type: 'integer'
            description: '''
            Port to the associated database.
            '''
          'silent':
            type: 'boolean'
            default: true
          'trim':
            type: 'boolean'
            default: false
        required: [
          'admin_password', 'command'
          'engine', 'host', 'admin_username'
        ]

## Handler

    handler = ({config}) ->
      {$status, stdout} = await @execute
        command: command config
        trim: config.trim
      if config.grep and typeof config.grep is 'string'
        return stdout: stdout, $status: stdout.split('\n').some (line) -> line is config.grep
      if config.grep and utils.regexp.is config.grep
        return stdout: stdout, $status: stdout.split('\n').some (line) -> config.grep.test line
      status: $status, stdout: stdout
        
## Escape

Escape SQL for Bash processing.

    escape = (sql) ->
      sql.replace /[\\"]/g, "\\$&"

## Command

Build the CLI query command.

    command = (...opts) ->
      config = {}
      for opt in opts
        opt = command: opt if typeof opt is 'string'
        for k, v of opt
          config[k] = v
      switch config.engine
        when 'mariadb', 'mysql'
          config.path ?= 'mysql'
          config.port ?= '3306'
          [
            "mysql"
            "-h#{config.host}"
            "-P#{config.port}"
            "-u#{config.admin_username}"
            "-p'#{config.admin_password}'"
            "-D#{config.database}" if config.database
            "#{config.mysql_config}" if config.mysql_config
            # -N, --skip-column-names   Don't write column names in results.
            # -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
            # -r, --raw                 Write fields without conversion. Used with --batch.
            "-N -s -r" if config.silent
            "-e \"#{escape config.command}\"" if config.command
          ].join ' '
        when 'postgresql'
          config.path ?= 'psql'
          config.port ?= '5432'
          [
            "PGPASSWORD=#{config.admin_password}"
            "psql"
            "-h #{config.host}"
            "-p #{config.port}"
            "-U #{config.admin_username}"
            "-d #{config.database}" if config.database
            "#{config.postgres_config}" if config.postgres_config
            # -t, --tuples-only        Print rows only
            # -A, --no-align           Unaligned table output mode
            # -q, --quiet              Run quietly (no messages, only query output)
            "-tAq"
            "-c \"#{config.command}\"" if config.command
          ].join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify config.engine}"
          
## Parse JDBC URL

Enrich the result of `url.parse` with the "engine" and "db" properties.

Example:

```
parse 'jdbc:mysql://host1:3306,host2:3306/hive?createDatabaseIfNotExist=true'
{ engine: 'mysql',
  addresses:
   [ { host: 'host1', port: '3306' },
     { host: 'host2', port: '3306' } ],
  database: 'hive' }
```

    jdbc = (jdbc) ->
      if /^jdbc:mysql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 3306
        engine: 'mysql'
        addresses: addresses
        database: database
      else if /^jdbc:postgresql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 5432
        engine: 'postgresql'
        addresses: addresses
        database: database
      else
        throw Error 'Invalid JDBC URL'

## Copy config

    connection_config = (opts) ->
      config = {}
      for k, v of opts
        continue unless k in ['admin_username', 'admin_password', 'database', 'engine', 'host', 'port', 'silent']
        config[k] = v
      config

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'db'
        definitions: definitions
      # Utils
      command: command
      connection_config: connection_config
      escape: escape
      jdbc: jdbc

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
