
# `nikita.db.schema`

Create or modify a schema for the destination database.

A PostgreSQL database contains one or multiple schemas which in turns contains
table, data types, functions, and operators.

Note, PostgreSQL default to the default `root` database while Nikita enforce the
presence of the targeted database.

## Create Schema example

```js
const {$status} = await nikita.db.schema({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_database'
  schema: 'my_schema'
})
console.info(`Schema created or modified: ${$status}`)
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
            The database name where the schema is created.
            '''
          'engine':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/engine'
          'host':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/host'
          'port':
            $ref: 'module://@nikitajs/db/src/query#/definitions/config/properties/port'
          'owner':
            type: 'string'
            description: '''
            The Schema owner. Alter Schema if schema already exists.
            '''
          'schema':
            type: 'string'
            description: '''
            New schema name.
            '''
        required: ['admin_username', 'admin_password', 'database', 'engine', 'host', 'schema']

## Handler

    handler = ({config}) ->
      {$status} = await @execute
        $shy: true
        code_skipped: 2
        command: command config, '\\dt'
      throw Error "Database does not exist #{config.database}" if !$status
      await @db.query config,
        command: "CREATE SCHEMA #{config.schema};"
        $unless_execute: command(config, "SELECT 1 FROM pg_namespace WHERE nspname = '#{config.schema}';") + " | grep 1"
      # Check if owner is the good one
      {stderr} = await @execute
        $if: config.owner?
        $unless_execute: command(config, '\\dn') + " | grep '#{config.schema}|#{config.owner}'"
        command: command config, "ALTER SCHEMA #{config.schema} OWNER TO #{config.owner};"
        code_skipped: 1
      throw Error "Owner #{config.owner} does not exists" if /^ERROR:\s\srole.*does\snot\sexist/.test stderr

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'db'
        definitions: definitions
      
## Dependencies

    {command} = require '../query'
