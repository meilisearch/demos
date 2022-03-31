
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)
path = require('path')

return unless tags.lxd

describe 'lxc.cluster.delete', ->

  they 'delete a cluster', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    nikita
      $ssh: ssh
    , ->
      cluster =
        networks:
          nktlxdpub:
            'ipv4.address': '192.0.2.1/28'
            'ipv4.nat': true
            'ipv6.address': 'none'
            'dns.domain': 'nikita.local'
        containers:
          'nikita-cluster-del-1':
            image: "images:#{images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
          'nikita-cluster-del-2':
            image: "images:#{images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
      # Create a 2 nodes cluster and stop it
      await @lxc.cluster cluster
      await @wait time: 200
      await @lxc.cluster.stop {...cluster, wait: true}
      # Status modified if cluster deleted
      {$status} = await @lxc.cluster.delete cluster
      $status.should.be.true()
      {list} = await @lxc.list
        filter: 'containers'
      # Containers and network shall no longer exist
      list.should.not.containEql 'nikita-cluster-del-1'
      list.should.not.containEql 'nikita-cluster-del-2'
      {list} = await @lxc.network.list()
      list.should.not.containEql 'nktlxdpub'
  
  describe 'option `force`', ->

    they 'when `false`, generate an error if cluster is running', ({ssh}) ->
      @timeout -1 # yum install take a lot of time
      nikita
        $ssh: ssh
      , ->
        cluster =
          networks:
            nktlxdpub:
              'ipv4.address': '192.0.2.1/28'
              'ipv4.nat': true
              'ipv6.address': 'none'
              'dns.domain': 'nikita.local'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
            'nikita-cluster-del-2':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
        await @lxc.cluster cluster
        await @wait time: 200
        await @lxc.cluster.delete cluster
        .should.be.rejectedWith /^NIKITA_EXECUTE_EXIT_CODE_INVALID:/
        await @lxc.cluster.delete {...cluster, force: true}

    they 'when `true`, force deletion', ({ssh}) ->
      @timeout -1 # yum install take a lot of time
      nikita
        $ssh: ssh
      , ->
        cluster =
          networks:
            nktlxdpub:
              'ipv4.address': '192.0.2.1/28'
              'ipv4.nat': true
              'ipv6.address': 'none'
              'dns.domain': 'nikita.local'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
            'nikita-cluster-del-2':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
        await @lxc.cluster cluster
        await @wait time: 200
        {$status} = await @lxc.cluster.delete {...cluster, force: true}
        $status.should.be.true()
        {list} = await @lxc.list
          filter: 'containers'
        list.should.not.containEql 'nikita-cluster-del-1'
        list.should.not.containEql 'nikita-cluster-del-2'
        {list} = await @lxc.network.list()
        list.should.not.containEql 'nktlxdpub'
