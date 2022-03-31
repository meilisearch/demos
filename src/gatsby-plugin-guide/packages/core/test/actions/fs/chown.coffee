
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.fs.chown', ->
  
  describe 'schema', ->

    return unless tags.api
    
    it 'require target', ->
      nikita.fs.chown()
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `fs.chown`:'
          '#/required config must have required property \'target\'.'
        ].join ' '
  
  describe 'usage', ->

    return unless tags.chown

    they 'throw error if target does not exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 1234
        .should.be.rejectedWith
          message: "NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got \"#{tmpdir}/a_file\""

    they 'use stat shortcircuit', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {stats} = await @fs.base.stat "#{tmpdir}/a_file"
        {$logs} = await @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 5678, stats: stats
        $logs
        .map (log) -> log.message
        .should.matchAny 'Stat short-circuit'

    they 'change both uid and gid as integer', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$logs} = await @fs.chown "#{tmpdir}/a_file", uid: 1234, gid: 5678
        $logs.map (log) -> log.message
        .should.match [
          'change uid from 0 to 1234'
          'change gid from 0 to 5678'
        ]

    they 'change only uid as integer', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$logs} = await @fs.chown "#{tmpdir}/a_file", uid: 1234
        $logs.map (log) -> log.message
        .should.matchAny 'change uid from 0 to 1234'

    they 'change only uid as string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$logs} = await @fs.chown "#{tmpdir}/a_file", uid: 'toto'
        $logs.map (log) -> log.message
        .should.matchAny 'change uid from 0 to 1234'

    they 'change only gid as integer', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$logs} = await @fs.chown "#{tmpdir}/a_file", gid: 5678
        $logs.map (log) -> log.message
        .should.matchAny 'change gid from 0 to 5678'

    they 'change only gid as string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$logs} = await @fs.chown "#{tmpdir}/a_file", gid: 'toto'
        $logs.map (log) -> log.message
        .should.matchAny 'change gid from 0 to 5678'

    they 'detect status with uid', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute """
        echo '' > '#{tmpdir}/a_file'
        userdel 'toto'; groupdel 'toto'
        groupadd 'toto' -g 5678; useradd 'toto' -u 1234 -g 5678
        """
        {$status} = await @fs.chown "#{tmpdir}/a_file", uid: 1234
        $status.should.be.true()
        {$status} = await @fs.chown "#{tmpdir}/a_file", uid: 1234
        $status.should.be.false()
