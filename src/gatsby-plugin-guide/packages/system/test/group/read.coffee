
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'system.group.read', ->
  
  describe 'with option `target`', ->
    return unless tags.posix
  
    they 'shy doesnt modify the status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        {$status} = await @system.group.read
          target: "#{tmpdir}/etc/group"
        $status.should.be.false()

    they 'activate locales', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        {groups} = await @system.group.read
          target: "#{tmpdir}/etc/group"
        groups.should.eql
          root: group: 'root', password: 'x', gid: 0, users: [ 'root' ]
          bin: group: 'bin', password: 'x', gid: 1, users: [ 'root', 'bin', 'daemon' ]

  describe 'without option `target`', ->
    return unless tags.system_user

    they 'use `getent` without target', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.group.remove 'toto'
        @system.group
          name: 'toto'
          gid: 1000
        {group} = await @system.group.read
          gid: 'toto'
        group.should.match
          group: 'toto'
          password: 'x'
          gid: 1000
          users: []
        @system.group.remove 'toto'
  
  describe 'option "gid"', ->
    return unless tags.posix
  
    they 'map a username to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:monsieur
          """
        {group} = await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: 'docker'
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'monsieur' ]
    
    they 'map a gid to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:monsieur
          """
        {group} = await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: '994'
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'monsieur' ]
  
