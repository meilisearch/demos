
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.detach', ->

  they 'Detach a network from a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @lxc.delete
          container: 'u0'
          force: true
        await @lxc.network.delete
          network: "nkt-detach-1"
      try
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        await @lxc.network
          network: "nkt-detach-1"
        await @lxc.network.attach
          network: "nkt-detach-1"
          container: "u0"
        {$status} = await @lxc.network.detach
          network: "nkt-detach-1"
          container: "u0"
        $status.should.be.true()
      finally
        await @clean()

  they 'Network already detached', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.delete
          container: 'u0'
          force: true
        @lxc.network.delete
          network: "nkt-detach-2"
      try
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        await @lxc.network
          network: "nkt-detach-2"
        {$status} = await @lxc.network.detach
          network: "nkt-detach-2"
          container: "u0"
        $status.should.be.false()
      finally
        @clean()
