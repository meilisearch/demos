
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)
path = require('path')

return unless tags.lxd

describe 'lxc.cluster.stop', ->

  they 'stop a running cluster', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    cluster =
      networks:
        nktlxdpub:
          'ipv4.address': '192.0.2.1/28'
          'ipv4.nat': true
          'ipv6.address': 'none'
          'dns.domain': 'nikita.local'
      containers:
        'nikita-cluster-stop-1':
          image: "images:#{images.alpine}"
          nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
        'nikita-cluster-stop-2':
          image: "images:#{images.alpine}"
          nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register ['clean'], ->
        await @lxc.cluster.delete {...cluster, force: true}
      @clean()
      await @lxc.cluster cluster
      await @wait time: 200
      {$status} = await @lxc.cluster.stop {...cluster, wait: true}
      $status.should.be.true()
      {config} = await @lxc.state
        container: 'nikita-cluster-stop-1'
      config.status.should.eql 'Stopped'
      {config} = await @lxc.state
        container: 'nikita-cluster-stop-2'
      config.status.should.eql 'Stopped'
      @clean()
