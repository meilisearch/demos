
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

for engine, _ of db

  describe "db.database.exists #{engine}", ->

    they 'database missing', ({ssh}) ->
      nikita
        $ssh: ssh
        db: db[engine]
      , ({tools: {status}}) ->
        {exists} = await @db.database.exists database: 'test_database_exists_0_db'
        exists.should.be.false()
        {exists} = await @db.database.exists 'test_database_exists_0_db'
        exists.should.be.false()
        status().should.be.false()

    they 'database exists', ({ssh}) ->
      nikita
        $ssh: ssh
        db: db[engine]
      , ({tools: {status}}) ->
        @db.database.remove 'test_database_exists_1_db', $shy: true
        @db.database 'test_database_exists_1_db', $shy: true
        {exists} = await @db.database.exists database: 'test_database_exists_1_db'
        exists.should.be.true()
        {exists} = await @db.database.exists 'test_database_exists_1_db'
        exists.should.be.true()
        @db.database.remove 'test_database_exists_1_db', $shy: true
        status().should.be.false()
