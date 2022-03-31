
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)


describe 'system.user.read', ->
  
  describe 'with option `target`', ->
    return unless tags.posix

    they 'shy doesnt modify the status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          """
        {$status} = await @system.user.read
          target: "#{tmpdir}/etc/passwd"
        $status.should.be.false()

    they 'return all users', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          """
        {users} = await @system.user.read
          target: "#{tmpdir}/etc/passwd"
        users.should.eql
          root: user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash'
          bin: user: 'bin', uid: 1, gid: 1, comment: 'bin', home: '/bin', shell: '/usr/bin/nologin'

  describe 'without option `target`', ->
    return unless tags.system_user

    they 'use `getent` without target', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.user.remove 'toto'
        @system.group.remove 'toto'
        @system.user
          name: 'toto'
          system: true
          uid: 1000
        {user} = await @system.user.read
          uid: 'toto'
        user.should.match
          user: 'toto'
          uid: 1000
          comment: ''
          home: '/home/toto'
          shell: '/bin/sh'
        @system.user.remove 'toto'
        @system.group.remove 'toto'

  describe 'option "uid"', ->
    return unless tags.posix

    they 'map a username to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          nobody:x:99:99:nobody:/:/usr/bin/nologin
          """
        {user} = await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: 'nobody'
        user.should.eql user: 'nobody', uid: 99, gid: 99, comment: 'nobody', home: '/', shell: '/usr/bin/nologin'

    they 'map a uid to user record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          nobody:x:99:99:nobody:/:/usr/bin/nologin
          """
        {user} = await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: '99'
        user.should.eql user: 'nobody', uid: 99, gid: 99, comment: 'nobody', home: '/', shell: '/usr/bin/nologin'

    they 'throw error if uid is a username dont match any user', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: 'nobody'
        .should.be.rejectedWith
          message: 'Invalid Option: no uid matching "nobody"'
    
    they 'throw error if uid is an id dont match any user', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: '99'
        .should.be.rejectedWith
          message: 'Invalid Option: no uid matching 99'
