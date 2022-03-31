
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.list', ->

  they 'list all networks', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.network.delete
          network: 'nkttestnetlist'
      await @clean()
      await @lxc.network
        network: 'nkttestnetlist'
        properties:
          'ipv4.address': '192.0.2.1/30'
          'dns.domain': 'nikita.net.test'
      {$status, list} = await @lxc.network.list()
      $status.should.be.true()
      list.should.containEql 'nkttestnetlist'
      await @clean()
