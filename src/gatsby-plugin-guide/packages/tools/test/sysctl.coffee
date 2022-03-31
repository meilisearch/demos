
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'tools.sysctl', ->

  they 'Write properties', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
        load: false
      $status.should.be.true()
      {$status} = await @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 10
        vm.overcommit_memory = 1
        """
  
  they 'Overwrite properties by default', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 10
        vm.overcommit_memory = 1
        """
      {$status} = await @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 1
        load: false
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 1
        """

  they 'Merge properties', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 1
        """
      {$status} = await @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
        merge: true
        load: false
      $status.should.be.true()
      {$status} = await @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.overcommit_memory': 1
        merge: true
        load: false
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 10
        vm.overcommit_memory = 1
        """

  they 'Merge properties with file containing empty lines', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 1
        
        """
      @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
        merge: true
        load: false
      @fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 10
        
        """

  they 'honors backup option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
        load: false
        backup: true
      @execute.assert
        bash: true
        command: "[[ `ls #{tmpdir}/sysctl.* | wc -l | sed 's/[ ]*//'` == '1' ]]" # sed to strip trailing space
      @tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 20
        load: false
        backup: true
      @execute.assert
        bash: true
        command: "[[ `ls #{tmpdir}/sysctl.* | wc -l | sed 's/[ ]*//'` == '2' ]]"

  describe 'comment', ->

    they 'Not preserved by default', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/sysctl.conf"
          content: """
          # System Kernel Variables
          vm.swappiness = 1
          # User Variables
          """
        {$status} = await @tools.sysctl
          target: "#{tmpdir}/sysctl.conf"
          properties:
            'vm.swappiness': 10
            'vm.overcommit_memory': 1
          merge: true
          load: false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/sysctl.conf"
          content: """
          vm.swappiness = 10
          vm.overcommit_memory = 1
          """

    they 'preserved when enabled', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/sysctl.conf"
          content: """
          # System Kernel Variables
          vm.swappiness = 1
          # User Variables
          """
        {$status} = await @tools.sysctl
          target: "#{tmpdir}/sysctl.conf"
          properties:
            'vm.swappiness': 10
            'vm.overcommit_memory': 1
          merge: true
          comment: true
          load: false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/sysctl.conf"
          content: """
          # System Kernel Variables
          vm.swappiness = 10
          # User Variables
          vm.overcommit_memory = 1
          """

    they 'handle equal sign in comment', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/sysctl.conf"
          content: """
          # Key = Value
          vm.swappiness = 1
          """
        @tools.sysctl
          target: "#{tmpdir}/sysctl.conf"
          properties:
            'vm.swappiness': 10
          merge: true
          comment: true
          load: false
        @fs.assert
          target: "#{tmpdir}/sysctl.conf"
          content: """
          # Key = Value
          vm.swappiness = 10
          """
