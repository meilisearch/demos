
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.systemd.resolved', ->

  they 'servers as a string', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.types.systemd.resolved
        target: "#{tmpdir}/resolved.conf"
        content:
          FallbackDNS: "1.1.1.1"
        reload: false
      @fs.assert
        target: "#{tmpdir}/resolved.conf"
        content: """
        [Resolve]
        FallbackDNS=1.1.1.1
        """
        trim: true

  they 'servers as an array', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.types.systemd.resolved
        target: "#{tmpdir}/resolved.conf"
        content:
          FallbackDNS: ["1.1.1.1", "9.9.9.10", "8.8.8.8", "2606:4700:4700::1111"]
        reload: false
      @fs.assert
        target: "#{tmpdir}/resolved.conf"
        content: """
        [Resolve]
        FallbackDNS=1.1.1.1 9.9.9.10 8.8.8.8 2606:4700:4700::1111
        """
        trim: true

  they 'merge values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.types.systemd.resolved
        target: "#{tmpdir}/resolved.conf"
        content:
          DNS: "ns0.fdn.fr"
        reload: false
      @fs.assert
        target: "#{tmpdir}/resolved.conf"
        content: """
        [Resolve]
        DNS=ns0.fdn.fr
        """
        trim: true
      @file.types.systemd.resolved
        target: "#{tmpdir}/resolved.conf"
        content:
          ReadEtcHosts: "true"
        merge: true
        reload: false
      @fs.assert
        target: "#{tmpdir}/resolved.conf"
        content: """
        [Resolve]
        DNS=ns0.fdn.fr
        ReadEtcHosts=true
        """
        trim: true
