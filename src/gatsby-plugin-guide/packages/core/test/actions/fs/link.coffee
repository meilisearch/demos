
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.link', ->

  describe 'validation', ->

    it 'missing source', ->
      nikita.fs.link
        target: '/path/to/file'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `fs.link`:'
          '#/required config must have required property \'source\'.'
        ].join ' '
    
    it 'missing target', ->
      nikita.fs.link
        source: '/path/to/file'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `fs.link`:'
          '#/required config must have required property \'target\'.'
        ].join ' '
  
  describe 'usage', ->

    they 'should link file', ({ssh}) ->
      # Create a non existing link
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.link # Link does not exist
          source: __filename
          target: "#{tmpdir}/link_test"
        $status.should.be.true()
        {$status} = await @fs.link # Link already exists
          source: __filename
          target: "#{tmpdir}/link_test"
        $status.should.be.false()
        @fs.assert
          target: "#{tmpdir}/link_test"
          filetype: 'symlink'

    they 'should link file with exec', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.link
          source: __filename
          target: "#{tmpdir}/test"
          exec: true
        $status.should.be.true()
        {$status} = await @fs.link
          source: __filename
          target: "#{tmpdir}/test"
          exec: true
        $status.should.be.false()
        @fs.assert
          target: "#{tmpdir}/test"
          content: """
          #!/bin/bash
          exec #{__filename} $@
          """
          trim: true
    
    they 'should link dir', ({ssh}) ->
      # Create a non existing link
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.link # Link does not exist
          source: __dirname
          target: "#{tmpdir}/link_test"
        $status.should.be.true()
        {$status} = await @fs.link # Link already exists
          $ssh: ssh
          source: __dirname
          target: "#{tmpdir}/link_test"
        $status.should.be.false()
        @fs.assert
          target: "#{tmpdir}/link_test"
          filetype: 'symlink'
    
    they 'should create parent directories', ({ssh}) ->
      # Create a non existing link
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.link
          source: __dirname
          target: "#{tmpdir}/test/dir/link_test"
        $status.should.be.true()
        await @fs.assert
          target: "#{tmpdir}/test/dir/link_test"
          type: 'symlink'
        {$status} = await @fs.link
          $ssh: ssh
          source: "#{__dirname}/merge.coffee"
          target: "#{tmpdir}/test/dir2/merge.coffee"
        $status.should.be.true()
        {$status} = await @fs.link
          $ssh: ssh
          source: "#{__dirname}/mkdir.coffee"
          target: "#{tmpdir}/test/dir2/mkdir.coffee"
        $status.should.be.true()

    they 'should override invalid link', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/invalid_file"
          content: 'error'
        await @fs.base.writeFile
          target: "#{tmpdir}/valid_file"
          content: 'ok'
        {$status} = await @fs.link
          source: "#{tmpdir}/invalid_file"
          target: "#{tmpdir}/file_link"
        $status.should.be.true()
        # await @fs.remove
        #   target: "#{tmpdir}/test/invalid_file"
        {$status} = await @fs.link
          source: "#{tmpdir}/test/valid_file"
          target: "#{tmpdir}/test/file_link"
        $status.should.be.true()
