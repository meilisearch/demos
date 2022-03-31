
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

describe 'db.schema postgres', ->

  return unless db.postgresql

  they 'status on new schema with no owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      @db.database.remove 'postgres_db_0'
      @db.database 'postgres_db_0'
      {$status} = await @db.schema
        schema: 'postgres_schema_0'
        database: 'postgres_db_0'
      $status.should.be.true()
      {$status} = await @db.schema
        schema: 'postgres_schema_0'
        database: 'postgres_db_0'
      $status.should.be.false()
      @db.database.remove 'postgres_db_0'

  they 'add new schema with not existing owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      try
        @db.database.remove 'postgres_db_1'
        @db.database 'postgres_db_1'
        await @db.schema
          schema: 'postgres_schema_1'
          database: 'postgres_db_1'
          owner: 'Johny'
        throw Error 'Oh no'
      catch err
        err.message.should.eql 'Owner Johny does not exists'
      finally
        @db.database.remove 'postgres_db_1'

  they 'add new schema with existing owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      @db.database.remove 'postgres_db_2'
      @db.user.remove 'postgres_user_2'
      @db.user
        username: 'postgres_user_2'
        password: 'postgres_user_2'
      @db.database
        database: 'postgres_db_2'
        user: 'postgres_user_2'
      {$status} = await @db.schema
        schema: 'postgres_schema_2'
        database: 'postgres_db_2'
        owner: 'postgres_user_2'
      $status.should.be.true()
      @db.database.remove 'postgres_db_2'
      @db.user.remove 'postgres_user_2'
    
  they 'add new schema with no owner (not existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      @db.schema
        schema: 'postgres_schema_4'
        database: 'postgres_db_4'
      .should.be.rejectedWith
        message: 'Database does not exist postgres_db_4'
  
  they 'add new schema after adding database and user', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      @db.database.remove 'postgres_db_5'
      @db.user.remove 'nikita_test_5'
      @db.user
        username: 'nikita_test_5'
        password: 'secret'
        engine: 'postgresql'
      @db.database
        user: 'nikita_test_5'
        database: 'postgres_db_5'
      {$status} = await @db.schema
        database: 'postgres_db_5'
        schema: 'postgres_schema_5'
        owner: 'nikita_test_5'
      $status.should.be.true()
      @db.database.remove 'postgres_db_5'
      @db.user.remove 'nikita_test_5'
