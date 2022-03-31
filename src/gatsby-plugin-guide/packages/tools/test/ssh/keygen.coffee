
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'tools.ssh.keygen', ->

  they 'a new key', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.ssh.keygen
        target: "#{tmpdir}/folder/id_rsa"
        bits: 2048
        comment: 'nikita'
      $status.should.be.true()
      {$status} = await @tools.ssh.keygen
        target: "#{tmpdir}/folder/id_rsa"
        bits: 2048
        comment: 'nikita'
      $status.should.be.false()

    
