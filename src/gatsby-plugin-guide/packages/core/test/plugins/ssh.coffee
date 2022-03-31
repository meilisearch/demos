
nikita = require '../../src'
utils = require '../../src/utils'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe '`plugins.ssh`', ->
  return unless tags.ssh
  
  describe 'from parent (action.ssh)', ->

    they 'from config in root action', ({ssh}) ->
      nikita $ssh: ssh, ({ssh: conn}) ->
        utils.ssh.compare(conn, ssh).should.be.true()

    they 'from config in child action', ({ssh}) ->
      nikita $ssh: ssh, ({ssh: conn}) ->
        @call -> @call ->
          utils.ssh.compare(conn, ssh).should.be.true()

    they 'from connection', ({ssh}) ->
      {ssh: conn} = await nikita.ssh.open ssh
      await nikita $ssh: conn, (action) ->
        @call -> @call ->
          utils.ssh.compare(conn, ssh).should.be.true()
      nikita.ssh.close ssh: conn

    they 'local if null', ({ssh}) ->
      nikita $ssh: ssh, ->
        @call ->
          @call $ssh: null, (action) ->
            (action.ssh is null).should.be.true()
            @call (action) ->
              # Ensure the ssh value is propagated to children
              (action.ssh is undefined).should.be.true()

    they 'local if false', ({ssh}) ->
      nikita $ssh: ssh, ->
        @call ->
          @call $ssh: false, (action) ->
            (action.ssh is null).should.be.true()
            @call (action) ->
              # Ensure the ssh value is propagated to children
              (action.ssh is undefined).should.be.true()
              
  describe 'from siblings (open/close)', ->
    
    they 'ssh.open', ({ssh}) ->
      nikita ->
        @ssh.open ssh
        try
          {stdout: whoami} = await @execute
            command: 'whoami'
            trim: true
          whoami.should.eql ssh.username
        finally
          @ssh.close()
