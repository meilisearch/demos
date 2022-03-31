
{merge} = require 'mixme'
nikita = require '../../src'
utils = require '../../src/utils'
{tags, config} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('mocha-they')(config.filter ({ssh}) -> !!ssh)

describe 'utils.ssh', ->
  return unless tags.api

  it 'immutable', ->
    config1 = config2 =
      host: '127.0.0.1',
      username: undefined,
      private_key_path: '~/.ssh/id_rsa'
    original = merge config1
    utils.ssh.compare(config1,config2)
    config1.should.eql original

  they 'compare two null', ({ssh}) ->
    utils.ssh.compare(null, null).should.be.true()
    utils.ssh.compare(null, false).should.be.true()

  they 'compare identical configs', ({ssh}) ->
    utils.ssh.compare(ssh, ssh).should.be.true()

  they 'compare identical connections', ({ssh}) ->
    try
      {ssh: conn1} = await nikita.ssh.open ssh
      {ssh: conn2} = await nikita.ssh.open ssh
      utils.ssh.compare(conn1, conn2).should.be.true()
    finally
      nikita.ssh.close ssh: conn1
      nikita.ssh.close ssh: conn2

  they 'compare a connection with a config', ({ssh}) ->
    try
      {ssh: conn} = await nikita.ssh.open ssh
      utils.ssh.compare(conn, ssh).should.be.true()
    finally
      nikita.ssh.close ssh: conn

  they 'compare a config with a connection', ({ssh}) ->
    try
      {ssh: conn} = await nikita.ssh.open ssh
      utils.ssh.compare(ssh, conn).should.be.true()
    finally
      nikita.ssh.close ssh: conn
