
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.exec', ->

  they 'a command with pipe inside', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-exec-1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-exec-1'
        start: true
      {$status, stdout} = await @lxc.exec
        container: 'nikita-exec-1'
        command: """
        cat /etc/os-release | egrep ^ID=
        """
      stdout.trim().should.eql 'ID=alpine'
      $status.should.be.true()
      await @clean()

  describe 'option `shell`', ->
    
    they 'default to shell', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-2', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-2'
          start: true
        {stdout} = await @lxc.exec
          container: 'nikita-exec-2'
          command: 'echo $0'
          trim: true
        stdout.should.eql 'sh'
        await @clean()
          
    they 'set to bash', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-3', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-3'
          start: true
        await @lxc.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-exec-3'
          command: 'apk add bash'
        {stdout} = await @lxc.exec
          container: 'nikita-exec-3'
          command: 'echo $0'
          shell: 'bash'
          trim: true
        stdout.should.eql 'bash'
        await @clean()

  describe 'option `trap`', ->

    they 'is enabled', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-4', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-4'
          start: true
        @lxc.exec
          container: 'nikita-exec-4'
          trap: true
          command: """
          false
          true
          """
        .should.be.rejectedWith
          exit_code: 1
        await @clean()

    they 'is disabled', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-5', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-5'
          start: true
        {$status, code} = await @lxc.exec
          container: 'nikita-exec-5'
          trap: false
          command: """
          false
          true
          """
        $status.should.be.true()
        code.should.eql 0
        await @clean()

  describe 'option `env`', ->

    they 'pass multiple variables', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-6', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-6'
          start: true
        {stdout} = await @lxc.exec
          container: 'nikita-exec-6'
          env:
            'ENV_VAR_1': 'value 1'
            'ENV_VAR_2': 'value 1'
          command: 'env'
        stdout
        .split('\n')
        .filter (line) -> /^ENV_VAR_/.test line
        .should.eql [ 'ENV_VAR_1=value 1', 'ENV_VAR_2=value 1' ]
        await @clean()

  describe 'option `user`', ->

    they 'non root user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-7', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-7'
          start: true
        @lxc.exec
          container: 'nikita-exec-7'
          command: 'adduser --uid 1234 --disabled-password nikita'
        {stdout} = await @lxc.exec
          container: 'nikita-exec-7'
          user: 1234
          command: 'whoami'
          trim: true
        stdout.should.eql 'nikita'
        await @clean()

  describe 'option `cwd`', ->

    they 'change directory', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-exec-8', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-exec-8'
          start: true
        {stdout} = await @lxc.exec
          container: 'nikita-exec-8'
          cwd: '/bin'
          command: 'pwd'
          trim: true
        stdout.should.eql '/bin'
        await @clean()
        
        
