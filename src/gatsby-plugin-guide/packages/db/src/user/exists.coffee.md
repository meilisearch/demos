
# `nikita.db.user.exists`

Check if a user exists in the database.

## Options

* `admin_username`   
  The login of the database administrator. It should have credentials to 
  create accounts.   
* `admin_password`   
  The password of the database administrator.   
* `database` (String)   
  The database name to which the user should be added.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `username`   
  The new user name.    
* `port`   
  Port to the associated database.   

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          # $ref: 'module://@nikitajs/db/src/query'
          'username':
            type: 'string'
            description: '''
            Name of the user to check for existance.
            '''
        required: [
          'username'
          'admin_username', 'admin_password', 'engine', 'host'
        ]

## Handler

    handler = ({config}) ->
      {stdout} = await @db.query connection_config(config),
        database: undefined
        command: switch config.engine
          when 'mariadb', 'mysql'
            "SELECT User FROM mysql.user WHERE User = '#{config.username}'"
          when 'postgresql'
            "SELECT '#{config.username}' FROM pg_roles WHERE rolname='#{config.username}'"
        trim: true
      exists: stdout is config.username

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'username'
        global: 'db'
        shy: true
        definitions: definitions

## Dependencies

    {connection_config} = require '../query'
