
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.system_info_disks

describe 'system.info.disks', ->

  they 'with no options', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status, disks} = await @system.info.disks()
      disks.length.should.be.above 0
      for disk in disks
        Object.keys(disk).should.eql [
          'df', 'filesystem', 'total', 'used',
          'available', 'available_pourcent', 'mountpoint'
        ]
        Object.keys(disk.df).should.eql [
          'source', 'fstype', 'itotal', 'iused',
          'iavail', 'ipcent', 'size', 'used', 'avail',
          'pcent', 'target'
        ]
