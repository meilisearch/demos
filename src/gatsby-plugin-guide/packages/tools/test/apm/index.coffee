
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm', ->

  they 'install a new package which is not already installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm
      name: 'package-list'
    $status.should.be.true()

  they 'attempt to install a package which is already installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm
      name: 'package-list'
    .tools.apm
      name: 'package-list'
    $status.should.be.false()
    
  they 'name as argument', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm 'package-list'
    $status.should.be.true()
