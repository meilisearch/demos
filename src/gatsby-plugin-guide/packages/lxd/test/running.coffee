
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.running', ->

  they 'Running container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-running-1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-running-1'
        start: true
      {$status} = await @lxc.running
        container: 'nikita-running-1'
      $status.should.be.true()
      await @clean()

  they 'Stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-running-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-running-2'
      {$status} = await @lxc.running
        container: 'nikita-running-2'
      $status.should.be.false()
      await @clean()
