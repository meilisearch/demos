
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.system_user

describe 'system.uid_gid', ->

  they 'convert names to id', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @system.user.remove 'toto'
      @system.group.remove ['toto', 'lulu']
      @system.group.remove 'lulu'
      @system.group 'toto', gid: 1234
      @system.group 'lulu', gid: 1235
      @system.user 'toto', uid: 1234, gid: 1235
      {uid, gid, default_gid} = await @system.uid_gid
        uid: 'toto'
        gid: 'toto'
      uid.should.eql 1234
      gid.should.eql 1234
      default_gid.should.eql 1235

  they 'leave id untouched', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @file
        target: "#{tmpdir}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        users:x:994:monsieur
        """
      @file
        target: "#{tmpdir}/etc/passwd"
        content: """
        root:x:0:0:root:/root:/bin/bash
        bin:x:1:1:bin:/bin:/usr/bin/nologin
        monsieur:x:99:99:monsieur:/:/home/monsieur
        """
      {$status, uid, gid} = await @system.uid_gid
        group_target: "#{tmpdir}/etc/group"
        passwd_target: "#{tmpdir}/etc/passwd"
        gid: '994'
        uid: '99'
      $status.should.be.false()
      uid.should.eql 99
      gid.should.eql 994

  they 'accept missing uid and gid', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status, uid, gid} = await @system.uid_gid
        group_target: "#{tmpdir}/etc/group"
        passwd_target: "#{tmpdir}/etc/passwd"
      $status.should.be.false()
      (uid is undefined).should.be.true()
      (gid is undefined).should.be.true()
  
