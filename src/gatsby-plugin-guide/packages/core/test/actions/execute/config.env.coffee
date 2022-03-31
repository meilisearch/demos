
stream = require 'stream'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.env', ->
  return unless tags.posix

  they 'invalid schema', ({ssh}) ->
    nikita $ssh: ssh, ->
      @execute
        command: 'whoami'
        env: ['oh no']
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration of action `execute`:'
          '#/properties/env/type config/env must be object,'
          'type is "object".'
        ].join ' '

  they 'from action', ({ssh}) ->
    # accepted environment variables
    # is determined by the AcceptEnv server setting
    # default values are "LANG,LC_*"
    nikita
      $ssh: ssh
    , ->
      {stdout} = await @execute
        command: 'env'
        env:
          # PATH required on NixOS, or env won't be avaiable
          'PATH': process.env['PATH']
          'LANG': 'tv'
      stdout.split('\n').includes('LANG=tv').should.be.true()

  they 'from parent', ({ssh}) ->
    nikita
      $ssh: ssh
      $env:
        # PATH required on NixOS, or env won't be avaiable
        'PATH': process.env['PATH']
        'LANG': 'tv'
    , ->
      {stdout} = await @execute
        command: 'env'
      stdout.split('\n').includes('LANG=tv').should.be.true()

  they 'process.env only in local', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      process.env['NIKITA_EXECUTE_ENV'] = '1'
      {stdout} = await @execute
        command: 'env'
      unless ssh # In local mode, default to process.env
        stdout.split('\n').includes('NIKITA_EXECUTE_ENV=1').should.be.true()
      else # But not in remote mode
        stdout.split('\n').includes('NIKITA_EXECUTE_ENV=1').should.be.false()
