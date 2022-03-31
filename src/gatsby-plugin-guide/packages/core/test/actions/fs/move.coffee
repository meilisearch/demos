
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.move', ->

  they 'error missing target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.move
        source: "#{tmpdir}/a_file"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `fs.move`:'
        '#/definitions/config/required config must have required property \'target\'.'
      ].join ' '

  they 'error missing source', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.move
        target: "#{tmpdir}/a_file"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `fs.move`:'
        '#/definitions/config/required config must have required property \'source\'.'
      ].join ' '

  they 'rename a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        target: "#{tmpdir}/org_file"
        content: ''
      {$status} = await @fs.move
        target: "#{tmpdir}/new_name"
        source: "#{tmpdir}/org_file"
      # .should.be.finally.containEql status: true
      $status.should.be.true()
      # The target file should exists
      await @fs.assert
        target: "#{tmpdir}/new_name"
      # The source file should no longer exists
      await @fs.assert
        target: "#{tmpdir}/org_file"
        not: true

  they 'rename a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.mkdir "#{tmpdir}/a_dir"
      await @fs.base.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: ''
      {$status} = await @fs.move
        source: "#{tmpdir}/a_dir"
        target: "#{tmpdir}/moved"
      $status.should.be.true()
      # The target file should exists
      await @fs.assert
        target: "#{tmpdir}/moved"
        filetype: 'directory'
      # The source file should no longer exists
      await @fs.assert
        target: "#{tmpdir}/a_dir"
        not: true

  they 'overwrite a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        target: "#{tmpdir}/src1.txt"
        content: 'hello'
      await @fs.base.writeFile
        target: "#{tmpdir}/src2.txt"
        content: 'hello'
      await @fs.base.writeFile
        target: "#{tmpdir}/dest.txt"
        content: 'overwritten'
      {$status} = await @fs.move
        source: "#{tmpdir}/src1.txt"
        target: "#{tmpdir}/dest.txt"
      $status.should.be.true()
      {$status} = await @fs.move # Move a file with the same content
        source: "#{tmpdir}/src2.txt"
        target: "#{tmpdir}/dest.txt"
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/dest.txt"
        content: 'hello'
      await @fs.assert
        target: "#{tmpdir}/src2.txt"
        not: true

  they 'force bypass checksum comparison', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        target: "#{tmpdir}/src.txt"
        content: 'hello'
      await @fs.base.writeFile
        target: "#{tmpdir}/dest.txt"
        content: 'hello'
      {$status} = await @fs.move
        source: "#{tmpdir}/src.txt"
        target: "#{tmpdir}/dest.txt"
        force: true
      $status.should.be.true()
