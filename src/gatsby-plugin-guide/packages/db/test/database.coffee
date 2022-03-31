
nikita = require '@nikitajs/core/lib'
{tags, config, db} = require './test'
they = require('mocha-they')(config)
{command} = require '../src/query'

return unless tags.db

for engine, _ of db then do (engine) ->

  describe "db.database #{engine}", ->

    they 'database as an argument', ({ssh}) ->
      {exists} = await nikita
        $ssh: ssh
        db: db[engine]
      .db.database.remove 'db_create_0'
      .db.database 'db_create_0'
      .db.database.exists 'db_create_0'
      exists.should.be.true()

    they 'output `$status`', ({ssh}) ->
      nikita
        $ssh: ssh
        db: db[engine]
      , ->
        @db.database.remove 'db_create_1'
        {$status} = await @db.database 'db_create_1'
        $status.should.be.true()
        {$status} = await @db.database 'db_create_1'
        $status.should.be.false()
        @db.database.remove 'db_create_1'

    describe 'user', ->

      they 'which is existing', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'db_create_3'
          @db.user.remove 'db_create_user_3'
          @db.user
            username: 'db_create_user_3'
            password: 'db_create_user_3'
          @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          # Todo: why not using nikita.user.exists ?
          {$status: user_exists} = await @execute
            command: switch engine
              when 'mariadb', 'mysql' then command(db[engine], database: 'mysql', "SELECT user FROM db WHERE db='db_create_3';") + " | grep 'db_create_user_3'"
              when 'postgresql' then command(db[engine], database: 'db_create_3', '\\l') + " | egrep '^db_create_user_3='"
          user_exists.should.be.true()
          @db.database.remove 'db_create_3'
          @db.user.remove 'db_create_user_3'

      they 'output `$status`', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'db_create_3'
          @db.user.remove 'db_create_user_3'
          @db.user
            username: 'db_create_user_3'
            password: 'db_create_user_3'
          @db.database
            database: 'db_create_3'
          {$status} = await @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          $status.should.be.true()
          {$status} = await @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          $status.should.be.false()
          @db.database.remove 'db_create_3'
          @db.user.remove 'db_create_user_3'

      they 'which is not existing', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          try
            @db.database.remove 'db_create_4'
            @db.user.remove 'db_create_user_4'
            await @db.database
              database: 'db_create_4'
              user: 'db_create_user_4'
            throw Error 'Oh no'
          catch err
              err.message.should.eql 'DB user does not exists: db_create_user_4'
          finally
            @db.database.remove 'db_create_4'
            @db.user.remove 'db_create_user_4'
