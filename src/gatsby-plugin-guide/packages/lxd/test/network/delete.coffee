
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.delete', ->

  they 'Delete a network', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.network
        network: "nkt-delete-1"
      {$status} = await @lxc.network.delete
        network: "nkt-delete-1"
      $status.should.be.true()
          
  they 'Network already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.network
        network: "nkt-delete-2"
      await @lxc.network.delete
        network: "nkt-delete-2"
      {$status} = await @lxc.network.delete
        network: "nkt-delete-2"
      $status.should.be.false()
