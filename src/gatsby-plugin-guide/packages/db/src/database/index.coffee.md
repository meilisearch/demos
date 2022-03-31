
# `nikita.db.database`

Create a database inside the destination datababse server.

## Create database example

```js
const {$status} = await nikita.database.db({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db',
})
console.info(`Database created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin_username':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/admin_username'
          'admin_password':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/admin_password'
          'database':
            type: 'string'
            description: '''
            The name of the database to create.
            '''
          'user':
            type: 'array'
            items: type: 'string'
            description: '''
            This users who will be granted superuser permissions.
            '''
          'engine':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/engine'
          'host':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/host'
          'port':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/port'
        required: ['admin_username', 'admin_password', 'database', 'engine', 'host']

## Handler

    handler = ({config, tools: {log}}) ->
      config.user ?= []
      config.user = [config.user] if typeof config.user is 'string'
      # Defines and check the engine type
      config.engine = config.engine.toLowerCase()
      log message: "Database engine set to #{config.engine}", level: 'DEBUG'
      # Create database unless exist
      log message: "Check if database #{config.database} exists", level: 'DEBUG'
      switch config.engine
        when 'mariadb', 'mysql'
          config.character_set ?= 'latin1' # MySQL default
          switch config.character_set
            when 'latin1' then config.collation ?= 'latin1_swedish_ci' # MySQL default
            when 'utf8' then config.collation ?= 'utf8_general_ci'
          command_database_create = command config, database: null, [
            "CREATE DATABASE #{config.database}"
            "DEFAULT CHARACTER SET #{config.character_set}"
            "DEFAULT COLLATE #{config.collation}" if config.collation
            ';'
          ].join ' '
        when 'postgresql'
          command_database_create = command config, database: null, "CREATE DATABASE #{config.database};"
      # Create the database if it does not exists
      {exists} = await @db.database.exists config
      unless exists
        await @execute
          command: command_database_create
        log message: "Database created: #{JSON.stringify config.database}", level: 'WARN'
      # Associate users to the database
      for user in config.user
        log message: "Check if user #{user} has PRIVILEGES on #{config.database} ", level: 'DEBUG'
        {exists} = await @db.user.exists config,
          username: user
        throw Error "DB user does not exists: #{user}" unless exists
        switch config.engine
          when 'mariadb', 'mysql'
            # command_has_privileges = command config, admin_username: null, username: user.username, password: user.password, database: config.database, "SHOW TABLES FROM pg_database"
            command_has_privileges = command(config, database: 'mysql', "SELECT user FROM db WHERE db='#{config.database}';") + " | grep '#{user}'"
            command_grant_privileges = command config, database: null, "GRANT ALL PRIVILEGES ON #{config.database}.* TO '#{user}' WITH GRANT OPTION;" # FLUSH PRIVILEGES
          when 'postgresql'
            command_has_privileges = command(config, database: config.database, "\\l") + " | egrep '^#{user}='"
            command_grant_privileges = command config, database: null, "GRANT ALL PRIVILEGES ON DATABASE #{config.database} TO #{user}"
        {$status} = await @execute
          command: """
          if #{command_has_privileges}; then
            echo '[INFO] User already with privileges'
            exit 3
          fi
          echo '[WARN] User privileges granted'
          #{command_grant_privileges}
          """
          code_skipped: 3
        log message: "Privileges granted: to #{JSON.stringify user} on #{JSON.stringify config.database}", level: 'WARN' if $status
      undefined

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'database'
        global: 'db'
        definitions: definitions

## Dependencies

    {command} = require '../query'
