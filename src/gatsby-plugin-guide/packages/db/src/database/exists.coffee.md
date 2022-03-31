
# `nikita.db.database.exists`

Check if a database exists.

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
            The database name to check for existance.
            '''
          'engine':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/engine'
          'host':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/host'
          'port':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/port'
        required: ['admin_username', 'admin_password', 'database', 'engine', 'host']

## Handler

    handler = ({config}) ->
      {$status} = await @db.query config,
        command: switch config.engine
          when 'mariadb', 'mysql'
            'SHOW DATABASES'
          when 'postgresql'
            # Not sure why we're not using \l
            "SELECT datname FROM pg_database WHERE datname = '#{config.database}'"
        database: null
        grep: config.database
      exists: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'database'
        global: 'db'
        shy: true
        definitions: definitions

## Dependencies

    {command} = require '../query'
