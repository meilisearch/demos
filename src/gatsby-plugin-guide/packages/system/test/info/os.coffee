
nikita = require '@nikitajs/core/lib'
{tags, config, expect} = require '../test'
they = require('mocha-they')(config)

return unless tags.system_info_os

describe 'system.info.os', ->

  they 'default options', ({ssh}) ->
    {os} = await nikita($ssh: ssh).system.info.os()
    Object.keys(os).sort().should.eql [
      'arch', 'distribution', 'linux_version', 'version'
    ]
    Object.keys(os).sort().should.eql Object.keys(expect.os)
    os.should.match expect.os
