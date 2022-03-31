
stream = require 'stream'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.env_export', ->
  return unless tags.posix

  they 'env in execute action', ({ssh}) ->
    nikita $ssh: ssh, ->
      logs = []
      {stdout} = await @execute
        command: 'env'
        env: 'MY_KEY': 'MY VALUE'
        env_export: true
        $log: ({log}) ->
          return unless log.type is 'text'
          logs.push log.message if /^Writing env export/.test log.message
      stdout.split('\n').includes('MY_KEY=MY VALUE').should.be.true()
      logs.length.should.eql 1

  they 'env in parent action', ({ssh}) ->
    nikita
      $ssh: ssh
      $env: 'MY_KEY': 'MY VALUE'
    ,->
      @call ->
        logs = []
        {stdout} = await @execute
          command: 'env'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        stdout.split('\n').includes('MY_KEY=MY VALUE').should.be.true()
        logs.length.should.eql 1

  they 'env merged with parent action', ({ssh}) ->
    nikita
      $ssh: ssh
      $env: 'MY_KEY_1': 'MY VALUE 1'
    ,->
      @call
        $env: 'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout} = await @execute
          command: 'env'
          env: 'MY_KEY_3': 'MY VALUE 3'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        stdout.split('\n').includes('MY_KEY_1=MY VALUE 1').should.be.true()
        stdout.split('\n').includes('MY_KEY_2=MY VALUE 2').should.be.true()
        stdout.split('\n').includes('MY_KEY_3=MY VALUE 3').should.be.true()
        logs.length.should.eql 1

  they.skip 'dont write if someone did it', ({ssh}) ->
    nikita
      $ssh: ssh
      $env: 'MY_KEY_1': 'MY VALUE 1'
    , ({metadata: {tmpdir}}) ->
      @call
        $env: 'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout, env_export_hash} = await @execute
          command: 'env'
          # env: 'MY_KEY_3': 'MY VALUE 3'
          env_export: true
        console.log '111111env_export_hash', env_export_hash
      @call
        $env: 'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout, env_export_hash} = await @execute
          command: 'env'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        # stdout.split('\n').includes('MY_KEY_1=MY VALUE 1').should.be.true()
        # stdout.split('\n').includes('MY_KEY_2=MY VALUE 2').should.be.true()
        # stdout.split('\n').includes('MY_KEY_3=MY VALUE 3').should.be.true()
        logs.length.should.eql 0
