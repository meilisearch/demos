
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.create', ->
  
  they 'schema dns.domain valid', ({ssh}) ->
    nikita
      $ssh: ssh
    .lxc.network
      network: "nkt-network-1"
      properties:
        'ipv4.address': '192.0.2.1/30'
        'dns.domain': 'nikita.local'
      $handler: (->)
            
  they 'schema dns.domain invalid', ({ssh}) ->
    nikita
      $ssh: ssh
    .lxc.network
      network: "nkt-network-1"
      properties:
        'ipv4.address': '192.0.2.1/30'
        'dns.domain': '(oo)'
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

  they 'Create a new network', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-2"
      try
        await @clean()
        {$status} = await @lxc.network
          network: "nkt-network-2"
        $status.should.be.true()
      finally
        await @clean()

  they 'Different types of config parameters', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-3"
      try
        {$status} = await @lxc.network
          network: "nkt-network-3"
          properties:
            'ipv4.address': "192.0.2.1/30"
            'ipv4.dhcp': false
            'bridge.mtu': 2000
        $status.should.be.true()
      finally
        await @clean()

  they 'Network already created', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-4"
      try
        await @lxc.network
          network: "nkt-network-4"
        {$status} = await @lxc.network
          network: "nkt-network-4"
        $status.should.be.false()
      finally
        await @clean()

  they 'Add new properties', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-5"
      try
        await @lxc.network
          network: "nkt-network-5"
        {$status} = await @lxc.network
          network: "nkt-network-5"
          properties:
            'ipv4.address': "192.0.2.1/30"
            'ipv4.dhcp': false
        $status.should.be.true()
      finally
        await @clean()

  they 'Change a property', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-6"
      try
        {$status} = await @lxc.network
          network: "nkt-network-6"
          properties:
            'ipv4.address': "192.0.2.1/30"
            'ipv4.dhcp': true
        $status.should.be.true()
        {$status} = await @lxc.network
          network: "nkt-network-6"
          properties:
            'ipv4.address': "192.0.2.1/30"
            'ipv4.dhcp': true
        $status.should.be.false()
        {$status} = await @lxc.network
          network: "nkt-network-6"
          properties:
            'ipv4.address': "192.0.2.1/30"
            'ipv4.dhcp': false
        $status.should.be.true()
      finally
        await @clean()

  they 'Configuration unchanged', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.network.delete
          network: "nkt-network-7"
      try
        await @lxc.network
          network: "nkt-network-7"
          properties:
            'ipv4.address': "192.0.2.1/30"
        {$status} = await @lxc.network
          network: "nkt-network-7"
          properties:
            'ipv4.address': "192.0.2.1/30"
        $status.should.be.false()
      finally
        await @clean()
