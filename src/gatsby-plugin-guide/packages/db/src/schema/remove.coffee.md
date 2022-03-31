
# `nikita.db.schema.remove`

Remove a schema from a database.

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
            The database name where the schema is registered.
            '''
          'engine':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/engine'
          'host':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/host'
          'port':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/port'
          'schema':
            type: 'string'
            description: '''
            New schema name.
            '''
        required: ['admin_username', 'admin_password', 'database', 'engine', 'host', 'schema']

## Handler

    handler = ({config}) ->
      {exists} = await @db.schema.exists config
      return false unless exists
      await @db.query config,
        command: "DROP SCHEMA IF EXISTS #{config.schema};"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'schema'
        global: 'db'
        definitions: definitions

## Dependencies

    {command} = require '../query'
