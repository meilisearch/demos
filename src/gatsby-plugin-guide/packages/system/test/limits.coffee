
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

describe 'system.limits', ->
  
  describe 'schema', ->

    return unless tags.api

    it 'system or user is required', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors were found in the configuration of action `system.limits`:'
            '#/oneOf config must match exactly one schema in oneOf, passingSchemas is null;'
            '#/oneOf/0/required config must have required property \'system\';'
            '#/oneOf/1/required config must have required property \'user\'.'
          ].join ' '

    it 'error if both system and user are defined', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          system: true
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  describe 'usage', ->

    return unless tags.system_limits

    they 'do nothing without any limits', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
        $status.should.be.false()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          not: true

    they 'nofile and noproc accept int', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2048
          nproc: 2048
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          content: """
          me    -    nofile    2048
          me    -    nproc    2048
          
          """

    they 'set global value', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          system: true
          nofile: 2048
          nproc: 2048
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          content: """
          *    -    nofile    2048
          *    -    nproc    2048
          
          """

    they 'specify hard and soft values', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile:
            soft: 2048
            hard: 4096
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          content: """
          me    soft    nofile    2048
          me    hard    nofile    4096
          
          """

    they 'detect changes', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2048
          nproc: 2048
          shy: true
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2047
          nproc: 2047
        $status.should.be.true()

    they 'detect no change', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2048
          nproc: 2048
          shy: true
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2048
          nproc: 2048
        $status.should.be.false()

    they 'nofile and noproc default to 75% of kernel limits', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert
          target: '/proc/sys/fs/file-max'
        {stdout: nofile} = await @execute
          command: 'cat /proc/sys/fs/file-max'
          trim: true
        nofile = Math.round parseInt(nofile, 10) * 0.75
        {stdout: nproc} = await @execute
          command: 'cat /proc/sys/kernel/pid_max'
          trim: true
        nproc = Math.round parseInt(nproc, 10) * 0.75
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: true
          nproc: true
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          content: """
          me    -    nofile    #{nofile}
          me    -    nproc    #{nproc}

          """
  
  describe 'system values', ->

    return unless tags.system_limits

    they 'raise an error if nofile is too high', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 1000000000
        .should.be.rejectedWith
          message: /^Invalid nofile configuration property.*$/

    they 'raise an error if nproc is too high', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nproc: 1000000000
        .should.be.rejectedWith
          message: /^Invalid nproc configuration property.*$/

    they 'raise an error if hardness is incoherent', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nproc:
            hard: 12
            toto: 24
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    they 'accept value \'unlimited\'', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.limits
          target: "#{tmpdir}/limits.conf"
          user: 'me'
          nofile: 2048
          nproc: 'unlimited'
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/limits.conf"
          content: """
          me    -    nofile    2048
          me    -    nproc    unlimited

          """
