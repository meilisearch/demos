
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

describe 'file.touch', ->
  
  describe 'schema', ->
    return unless tags.api
    
    it 'inheric file schema', ->
      nikita.file.touch
        mode: 0o1700
        target: '/tmp/fake'
      , ({config}) ->
        config.mode.should.eql 0o1700
        
    it 'convert string argument to config.target', ->
      nikita.file.touch '/tmp/fake', ({config}) ->
        config.target.should.eql '/tmp/fake'
    
  describe 'usage', ->
    return unless tags.posix
    
    they 'as a target option', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: true
        @file.touch
          target: "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: ''

    they 'as a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: true
        @file.touch "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: ''

    they 'an existing file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: true
        @file.touch
          target: "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: false

    they 'change permissions', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/a_file"
          mode: 0o0700
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0700

    they 'do not change permissions on existing file if not specified', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/a_file"
          mode: 0o666
        .should.be.finally.containEql $status: true
        @file.touch
          target: "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0666

    they 'create valid parent dir', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/subdir/a_file"
          mode:'0640'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/subdir"
          mode: 0o0751

    they 'modify time but not status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch "#{tmpdir}/a_file"
        {stats: stat_org} = await @fs.base.stat target: "#{tmpdir}/a_file"
        # Bypass fs cache, a value of 500 is not always enough
        await new Promise (resolve) -> setTimeout resolve, 1000
        @file.touch "#{tmpdir}/a_file"
        .should.be.finally.containEql $status: false
        {stats: stat_new} = await @fs.base.stat target: "#{tmpdir}/a_file"
        stat_org.mtime.should.not.eql stat_new.mtime

    they 'missing target', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          mode: 0o0644
        .should.be.rejectedWith [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `file.touch`:'
          '#/required config must have required property \'target\'.'
        ].join ' '
