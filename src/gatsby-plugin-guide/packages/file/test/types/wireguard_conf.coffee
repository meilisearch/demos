
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.wireguard_conf', ->

  they 'simple values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.wireguard_conf
        target: "#{tmpdir}/wireguard.conf"
        content:
          'Interface':
            'Address': '10.10.11.1/24'
            'ListenPort': '51820'
            'PrivateKey': 'XXX/XXX+XXX='
          'Peer':
            'PublicKey': 'XXX='
            'AllowedIPs': '10.10.11.0/24'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/wireguard.conf"
        content: """
        [Interface]
        Address = 10.10.11.1/24
        ListenPort = 51820
        PrivateKey = XXX/XXX+XXX=
        [Peer]
        PublicKey = XXX=
        AllowedIPs = 10.10.11.0/24
        
        """

  they 'multiple values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.wireguard_conf
        target: "#{tmpdir}/wireguard.conf"
        content:
          'Interface':
            'Address': [
              '10.10.11.1/24'
              'fd86:ea04:1111::1/64'
            ]
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/wireguard.conf"
        content: """
        [Interface]
        Address = 10.10.11.1/24
        Address = fd86:ea04:1111::1/64
        
        """
