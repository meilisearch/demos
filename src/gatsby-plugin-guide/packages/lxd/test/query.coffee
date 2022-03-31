
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.query', ->

  they 'with path', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status, data} = await @lxc.query
        path: '/1.0'
      $status.should.eql true
      data.api_version.should.eql '1.0'
