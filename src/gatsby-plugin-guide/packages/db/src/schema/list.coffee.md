
# `nikita.db.schema.list`

List the PostgreSQL schemas of a database.

## Create Schema example

```js
const {schemas} = await nikita.db.schema.list({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
schemas.map( ({name, owner}) => {
  console.info(`Schema is ${name} and owner is ${owner}`)
})
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
            The database name storing the schemas.
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
      {stdout} = await @db.query config,
        command: '\\dn'
        trim: true
      schemas = utils.string
      .lines(stdout)
      .map (line) ->
        [name, owner] = line.split '|'
        name: name
        owner: owner
      schemas: schemas

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'database'
        global: 'db'
        definitions: definitions
      
## Dependencies

    utils = require '@nikitajs/core/lib/utils'
