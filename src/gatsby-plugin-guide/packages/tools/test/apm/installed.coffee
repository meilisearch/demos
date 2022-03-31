
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm.install', ->

  they 'apm is installed on system', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
    .tools.apm.installed()
    $status.should.be.true()
