
connect = require 'ssh2-connect'
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.ssh.open', ->
  
  describe 'schema', ->
    return unless tags.api
    
    they 'config.host', ({ssh}) ->
      nikita
      .ssh.open {...ssh, host: '_invalid_', debug: undefined}
      .should.be.rejectedWith code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      
  describe 'usage', ->
    return unless tags.ssh

    they 'from config', ({ssh}) ->
      nikita ->
        {ssh, $status} = await @ssh.open ssh
        utils.ssh.is( ssh ).should.be.true()
        @ssh.close ssh: ssh
    
