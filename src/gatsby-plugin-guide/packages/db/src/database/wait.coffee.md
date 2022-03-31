
# `nikita.db.database.wait`

Wait for the creation of a database.

## Create Database example

```js
const {$status} = await nikita.db.wait({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
console.info(`Did database existed initially: ${!$status}`)
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
            The database name to wait for.
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
      # Command
      await @execute.wait
        command: switch config.engine
          when 'mariadb', 'mysql'
            command(config, database: null, "show databases") + " | grep '#{config.database}'"
          when 'postgresql'
            command(config, database: null, null) + " -l | cut -d \\| -f 1 | grep -qw '#{config.database}'"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'database'
        global: 'db'
        definitions: definitions

## Dependencies

    {command} = require '../query'
