
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.stop', ->

  they 'Already stopped', ({ssh})  ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-stop-1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-stop-1'
      {$status} = await @lxc.stop
        container: 'nikita-stop-1'
      $status.should.be.false()
      await @clean()

  they 'Stop a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-stop-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-stop-2'
        start: true
      {$status} = await @lxc.stop
        container: 'nikita-stop-2'
      $status.should.be.true()
      await @clean()
