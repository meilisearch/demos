
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.copy', ->

  they 'a file to a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_directory"
      await @fs.base.copy
        source: "{{parent.metadata.tmpdir}}/a_file"
        target: "{{parent.metadata.tmpdir}}/a_directory"
      @fs.base.readFile
        target: "{{parent.metadata.tmpdir}}/a_directory/a_file"
        encoding: 'utf8'
      .should.be.finally.containEql data: 'some content'

  they 'a file to a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'some source content'
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        content: 'some target content'
      await @fs.base.copy
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      @fs.base.readFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        encoding: 'utf8'
      .should.be.finally.containEql data: 'some source content'

  they 'option argument default to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'some content'
      await @fs.base.copy "{{parent.metadata.tmpdir}}/a_target",
        source: "{{parent.metadata.tmpdir}}/a_source"
      @fs.base.readFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        encoding: 'utf8'
      .should.be.finally.containEql data: 'some content'
    
  they 'NIKITA_FS_COPY_TARGET_ENOENT target does not exits', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'some content'
      @fs.base.copy
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_dir/a_target"
      .should.be.rejectedWith
        code: 'NIKITA_FS_COPY_TARGET_ENOENT'
        message: [
          'NIKITA_FS_COPY_TARGET_ENOENT:'
          'target parent directory does not exists or is not a directory,'
          "got #{JSON.stringify "#{tmpdir}/a_dir/a_target"}"
        ].join ' '
        exit_code: 2
        errno: -2
        syscall: 'open'
        path: "#{tmpdir}/a_dir/a_target"
