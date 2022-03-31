
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'system.user', ->

  describe 'schema', ->
    return unless tags.api
  
    it 'shell', ->
      {shell} = await nikita.system.user
        shell: true
        name: 'gollum'
      , ({config}) -> config
      shell.should.eql '/bin/sh'
      {shell} = await nikita.system.user
        name: 'gollum'
      , ({config}) -> config
      shell.should.eql '/bin/sh'
      {shell} = await nikita.system.user
        shell: false
        name: 'gollum'
      , ({config}) -> config
      shell.should.eql '/sbin/nologin'
  
  describe 'usage', ->
    return unless tags.system_user
    
    they 'accept only user name', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.user.remove 'toto'
        @system.group.remove 'toto'
        {$status} = await @system.user 'toto'
        $status.should.be.true()
        {$status} = await @system.user 'toto'
        $status.should.be.false()

    they 'created with a uid', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.user.remove 'toto'
        @system.group.remove 'toto'
        {$status} = await @system.user 'toto', uid: 1234
        $status.should.be.true()
        {$status} = await @system.user 'toto', uid: 1235
        $status.should.be.true()
        {$status} = await @system.user 'toto', uid: 1235
        $status.should.be.false()
        {$status} = await @system.user 'toto'
        $status.should.be.false()

    they 'created without a uid', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.user.remove 'toto'
        @system.group.remove 'toto'
        {$status} = await @system.user 'toto'
        $status.should.be.true()
        {$status} = await @system.user 'toto', uid: 1235
        $status.should.be.true()
        {$status} = await @system.user 'toto'
        $status.should.be.false()

    they 'parent home does not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @system.user.remove 'toto'
        await @system.group.remove 'toto'
        await @fs.remove "#{tmpdir}/toto/subdir"
        {$status} = await @system.user 'toto', home: "#{tmpdir}/toto/subdir"
        $status.should.be.true()
        @fs.assert "#{tmpdir}/toto",
          mode: [0o0644, 0o0755]
          uid: 0
          gid: 0
