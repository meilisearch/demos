
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

for engine, _ of db

  describe "db.database.wait #{engine}", ->

    they 'is already created', ({ssh}) ->
      nikita
        $ssh: ssh
        db: db[engine]
      , ->
        @db.database.remove 'db_wait_1'
        @db.database 'db_wait_0'
        {$status} = await @db.database.wait 'db_wait_0'
        $status.should.be.false()
        @db.database.remove 'db_wait_0'

    they 'is not yet created', ({ssh}) ->
      setTimeout ->
        nikita
          $ssh: ssh
          db: db[engine]
        .db.database 'db_wait_1'
      , 200
      nikita
        $ssh: ssh
        db: db[engine]
      , ->
        @db.database.remove 'db_wait_1'
        {$status} = await @db.database.wait 'db_wait_1'
        $status.should.be.true()
        @db.database.remove 'db_wait_1'
