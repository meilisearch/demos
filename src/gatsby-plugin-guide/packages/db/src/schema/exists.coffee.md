
# `nikita.db.schema.exists`

Create a database for the destination database.

## Create Schema example

```js
const {exists} = await nikita.db.schema.exists({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
console.info(`Schema exists: ${exists}`)
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
      {$status} = await @db.query config,
        command: "SELECT 1 FROM pg_namespace WHERE nspname = '#{config.schema}';"
        grep: '1'
      exists: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'db'
        definitions: definitions
      
## Dependencies

    {command} = require '../query'
