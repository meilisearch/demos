
nikita = require '../../../../src'
utils = require '../../../../src/utils'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.createWriteStream', ->
  
  describe 'validation', ->

    it 'schema stream is required', ->
      nikita.fs.base.createWriteStream
        target: "a_file"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of'
        'action `fs.base.createWriteStream`:'
        '#/required config must have required property \'stream\'.'
      ].join ' '

    it 'schema target is required', ->
      nikita.fs.base.createWriteStream
        stream: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of'
        'action `fs.base.createWriteStream`:'
        '#/required config must have required property \'target\'.'
      ].join ' '

    they 'NIKITA_FS_CWS_TARGET_ENOENT if parent direction does not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.createWriteStream
          target: "#{tmpdir}/a_dir/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        .should.be.rejectedWith
          message: "NIKITA_FS_CWS_TARGET_ENOENT: fail to write a file, location is \"#{tmpdir}/a_dir/a_file\"."
          errno: -2
          code: 'NIKITA_FS_CWS_TARGET_ENOENT'
          syscall: 'open'
          path: "#{tmpdir}/a_dir/a_file"
  
  describe 'usage', ->

    they 'write a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.base.createWriteStream
          target: "{{parent.metadata.tmpdir}}/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        @fs.base.readFile
          target: "{{parent.metadata.tmpdir}}/a_file"
        .should.be.finally.containEql data: Buffer.from 'hello'

    they 'argument `target`', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.base.createWriteStream "{{parent.metadata.tmpdir}}/a_file",
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        @fs.base.readFile
          target: "{{parent.metadata.tmpdir}}/a_file"
        .should.be.finally.containEql data: Buffer.from 'hello'

    they 'config `mode`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: ''
          mode: 0o0611
        {stats} = await @fs.base.stat "#{tmpdir}/a_file"
        utils.mode.compare(stats.mode, 0o0611).should.be.true()
    
    they.skip 'config `flags` equal "a"', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        tmpdir: true
      , ->
        await @fs.base.createWriteStream
          target: "{{parent.metadata.tmpdir}}/a_file"
          stream: (ws) ->
            ws.write 'hello'
            ws.end()
        await @fs.base.createWriteStream
          target: "{{parent.metadata.tmpdir}}/a_file"
          flags: 'a'
          stream: (ws) ->
            ws.write ' nikita'
            ws.end()
        @fs.base.readFile
          target: "{{parent.metadata.tmpdir}}/a_file"
        .should.be.finally.containEql data: "hello nikita"
    
