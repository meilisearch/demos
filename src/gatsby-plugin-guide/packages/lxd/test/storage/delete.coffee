
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.storage.delete', ->

  they 'Delete a storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: "nikita-storage-delete-1"
        driver: "zfs"
      {$status} = await @lxc.storage.delete
        name: "nikita-storage-delete-1"
      $status.should.be.true()
      
  they 'Storage already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: "nikita-storage-delete-2"
        driver: "zfs"
      await @lxc.storage.delete
        name: "nikita-storage-delete-2"
      {$status} = await @lxc.storage.delete
        name: "nikita-storage-delete-2"
      $status.should.be.false()
  
