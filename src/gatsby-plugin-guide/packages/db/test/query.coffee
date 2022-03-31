
nikita = require '@nikitajs/core/lib'
{jdbc} = require '../src/query'
{tags, config, db} = require './test'
they = require('mocha-they')(config)

return unless tags.db

describe "db.query", ->
  
  for engine, _ of db then do (engine) ->

    describe "#{engine}", ->

      they 'schema required', ({ssh}) ->
        nikita
          $ssh: ssh
        .db.query
          command: 'select * from doesntmatter'
        .should.be.rejectedWith [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:"
          "multiple errors were found in the configuration of action `db.query`:"
          "#/definitions/config/required config must have required property 'admin_password';"
          "#/definitions/config/required config must have required property 'admin_username';"
          "#/definitions/config/required config must have required property 'engine';"
          "#/definitions/config/required config must have required property 'host'."
        ].join ' '

      they 'config command', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'test_query_1'
          @db.database 'test_query_1'
          {$status, stdout} = await @db.query
            database: 'test_query_1'
            command: """
            CREATE TABLE a_table (a_col CHAR(5));
            INSERT INTO a_table (a_col) VALUES ('value');
            select * from a_table
            """
          $status.should.be.true()
          stdout.should.eql 'value\n'

      they 'config trim', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'test_query_1'
          @db.database 'test_query_1'
          {stdout} = await @db.query
            database: 'test_query_1'
            command: """
            CREATE TABLE a_table (a_col CHAR(5));
            INSERT INTO a_table (a_col) VALUES ('value');
            select * from a_table
            """
            trim: true
          stdout.should.eql 'value'

      they 'config grep with string', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'test_query_1'
          @db.database 'test_query_1'
          @db.query
            database: 'test_query_1'
            command: '''
            CREATE TABLE a_table (a_col CHAR(5));
            INSERT INTO a_table (a_col) VALUES ('value');
            '''
          {$status} = await @db.query
            database: 'test_query_1'
            command: '''
            select * from a_table
            '''
            grep: 'value'
          $status.should.be.true()
          {$status} = await @db.query
            database: 'test_query_1'
            command: 'select * from a_table'
            grep: 'invalid value'
          $status.should.be.false()

      they 'config grep with regexp', ({ssh}) ->
        nikita
          $ssh: ssh
          db: db[engine]
        , ->
          @db.database.remove 'test_query_1'
          @db.database 'test_query_1'
          @db.query
            database: 'test_query_1'
            command: '''
            CREATE TABLE a_table (a_col CHAR(5));
            INSERT INTO a_table (a_col) VALUES ('value');
            '''
          {$status} = await @db.query
            database: 'test_query_1'
            command: 'select * from a_table'
            grep: /^val.*$/
          $status.should.be.true()
          {$status} = await @db.query
            database: 'test_query_1'
            command: 'select * from a_table'
            grep: /^val$/
          $status.should.be.false()

  describe 'jdbc', ->

    it 'get default port', ->
      jdbc('jdbc:mysql://localhost/my_db').should.eql
        engine: 'mysql',
        addresses: [ { host: 'localhost', port: 3306 } ],
        database: 'my_db'
      jdbc('jdbc:postgresql://localhost/my_db').should.eql
        engine: 'postgresql',
        addresses: [ { host: 'localhost', port: 5432 } ],
        database: 'my_db'

    it 'get database', ->
      jdbc('jdbc:mysql://master3.ryba:3306/my_db?a_param=true').database.should.eql 'my_db'
