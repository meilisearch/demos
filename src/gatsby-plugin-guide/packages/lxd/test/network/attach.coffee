
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.attach', ->

  they 'Attach a network to a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @lxc.delete
          container: 'u0'
          force: true
        await @lxc.network.delete
          network: "nkt-attach-1"
      try
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        await @lxc.network
          network: "nkt-attach-1"
        {$status} = await @lxc.network.attach
          network: "nkt-attach-1"
          container: "u0"
        $status.should.be.true()
      finally
        await @clean()

  they 'Network already attached', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @lxc.delete
          container: 'u0'
          force: true
        await @lxc.network.delete
          network: "nkt-attach-2"
      await @clean()
      try
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        await @lxc.network
          network: "nkt-attach-2"
        await @lxc.network.attach
          network: "nkt-attach-2"
          container: "u0"
        {$status} = await @lxc.network.attach
          network: "nkt-attach-2"
          container: "u0"
        $status.should.be.false()
      finally
        await @clean()
