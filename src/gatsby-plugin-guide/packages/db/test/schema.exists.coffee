
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

describe 'db.schema.exists postgres', ->

  return unless db.postgresql

  they 'output exists', ({ssh}) ->
    nikita
      $ssh: ssh
      db: db.postgresql
    , ->
      @db.database.remove 'schema_exists_0'
      @db.database 'schema_exists_0'
      {exists} = await @db.schema.exists
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      exists.should.be.false()
      await @db.schema
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      {exists} = await @db.schema.exists
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      exists.should.be.true()
      @db.database.remove 'schema_exists_0'
