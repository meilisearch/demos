
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm.uninstall', ->

  they 'uninstall an installed apm package', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    $status.should.be.true()

  they 'uninstall an apm package which is not installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    $status.should.be.false()

  they 'name as argument', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm
      name: 'package-list'
    .tools.apm.uninstall 'package-list'
    $status.should.be.true()
