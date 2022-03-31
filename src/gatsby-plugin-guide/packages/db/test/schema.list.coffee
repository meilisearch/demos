
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

describe 'db.schema.list postgres', ->

  return unless db.postgresql

  they 'list', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      # Clean
      @db.database.remove 'db_schema_list_0_db'
      @db.user.remove 'db_schema_list_0_usr'
      # Prepare
      @db.user
        username: 'db_schema_list_0_usr'
        password: 'secret'
      @db.database
        user: 'db_schema_list_0_usr'
        database: 'db_schema_list_0_db'
      # Without a user
      @db.schema
        database: 'db_schema_list_0_db'
        schema: 'db_schema_list_0_sch_0'
      # With a user
      @db.schema
        database: 'db_schema_list_0_db'
        schema: 'db_schema_list_0_sch_1'
        owner: 'db_schema_list_0_usr'
      # Test
      {schemas} = await @db.schema.list 'db_schema_list_0_db'
      schemas.should.eql [
        { name: 'db_schema_list_0_sch_0', owner: 'root' }
        { name: 'db_schema_list_0_sch_1', owner: 'db_schema_list_0_usr' }
        { name: 'public', owner: 'root' }
      ]
      # Clean
      @db.database.remove 'db_schema_list_0_db'
      @db.user.remove 'db_schema_list_0_usr'
