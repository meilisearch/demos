
nikita = require '../../../src'
{tags, config, conditions_if_os} = require '../../test'
they = require('mocha-they')(config)

describe 'plugin.conditions unless_os', ->
  return unless tags.conditions_if_os

  they 'match distribution string', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {$status} = await @call
        $unless_os: distribution: conditions_if_os.distribution
        $handler: -> true
      $status.should.be.false()
      {$status} = await @call
        $unless_os: distribution: 'invalid'
        $handler: -> true
        $ssh: ssh
      $status.should.be.true()

  they 'match distribution array', ({ssh}) ->
    {$status} = await nikita
      $unless_os: distribution: ['invalid1', 'invalid2']
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
    
  they 'match distribution string and version string', ({ssh}) ->
    # Arch Linux only has linux_version
    if conditions_if_os.version
    then condition = version: '1'
    else condition = linux_version: '1'
    {$status} = await nikita
      $unless_os: {...condition, distribution: 'invalid' }
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match Linux version string', ({ssh}) ->
    {$status} = await nikita
      $unless_os:
        linux_version: '1'
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
    
  they 'match distribution string, version string, Linux version string and arch string', ({ssh}) ->
    {$status} = await nikita
      $unless_os: conditions_if_os
      $handler: -> true
      $ssh: ssh
    $status.should.be.false()

  they 'match array', ({ssh}) ->
    {$status} = await nikita
      $unless_os: [
        { distribution: ['invalid1', 'invalid2'] }
        { distribution: 'invalid' }
      ]
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
