
nikita = require '../../../src'
{tags, config, conditions_if_os} = require '../../test'
they = require('mocha-they')(config)

describe 'plugin.conditions if_os', ->
  return unless tags.conditions_if_os

  they 'match distribution string', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @call
        $if_os: distribution: conditions_if_os.distribution
        $handler: -> true
      $status.should.be.true()
      {$status} = await @call
        $if_os: distribution: 'invalid'
        $handler: -> true
        $ssh: ssh
      $status.should.be.false()

  they 'match distribution array', ({ssh}) ->
    {$status} = await nikita
      $if_os: distribution: [conditions_if_os.distribution, 'invalid']
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match distribution string and version string', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        distribution: conditions_if_os.distribution
        version: conditions_if_os.version
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match Linux version string', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        linux_version: conditions_if_os.linux_version
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match distribution string and major version', ({ssh}) ->
    # Arch Linux has only linux_version
    if conditions_if_os.version
    then condition = version: conditions_if_os.version
    else condition = linux_version: conditions_if_os.linux_version
    {$status} = await nikita
      $if_os: condition,
        distribution: conditions_if_os.distribution
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match major Linux version', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        linux_version: conditions_if_os.linux_version.split('.')[0]
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match arch string', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        arch: conditions_if_os.arch
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match distribution string, version string, Linux version string and arch string', ({ssh}) ->
    {$status} = await nikita
      $if_os: conditions_if_os
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match array', ({ssh}) ->
    # Arch Linux has only linux_version
    if conditions_if_os.version
    then condition = [version: conditions_if_os.version]
    else condition = [linux_version: conditions_if_os.linux_version]
    condition.push 8
    {$status} = await nikita
      $if_os: [
        distribution: conditions_if_os.distribution
      ,
        condition
      ]
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
