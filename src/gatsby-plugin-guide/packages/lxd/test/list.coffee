
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.list', ->

  they 'list all instances', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-list-c1', force: true
        @lxc.delete 'nikita-list-vm1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-list-c1'
      await @lxc.init
        $if: tags.lxd_vm
        image: "images:#{images.alpine}"
        container: 'nikita-list-vm1'
        vm: true
      await @wait time: 200
      {$status, list} = await @lxc.list()
      $status.should.be.true()
      list.should.containEql 'nikita-list-c1'
      list.should.containEql 'nikita-list-vm1' if tags.lxd_vm
      await @clean()

  describe 'option `filter`', ->
  
    they 'when `containers`, only display containers', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-list-c1', force: true
          @lxc.delete 'nikita-list-vm1', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-list-c1'
        await @lxc.init
          $if: tags.lxd_vm
          image: "images:#{images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @lxc.list
          filter: 'containers'
        $status.should.be.true()
        list.should.containEql 'nikita-list-c1'
        list.should.not.containEql 'nikita-list-vm1' if tags.lxd_vm
        await @clean()

    they 'when `virtual-machines`, only display VMs', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-list-c1', force: true
          @lxc.delete 'nikita-list-vm1', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-list-c1'
        await @lxc.init
          $if: tags.lxd_vm
          image: "images:#{images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @lxc.list
          filter: 'virtual-machines'
        $status.should.be.true()
        list.should.not.containEql 'nikita-list-c1'
        list.should.containEql 'nikita-list-vm1' if tags.lxd_vm
        await @clean()
