
fs = require 'ssh2-fs'
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.rmdir', ->

  they 'dir is removed', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      @fs.base.exists
        target: "{{parent.metadata.tmpdir}}/a_dir"
      .should.be.finally.containEql exists: false

  they 'config recursive false, default', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_dir/a_file"
        content: ''
      @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      .should.be.rejectedWith
        code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'

  they 'config recursive true', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_dir/a_file"
        content: ''
      await @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
        recursive: true
      await @fs.assert
        target: "{{parent.metadata.tmpdir}}/a_dir"
        not: true

  they 'NIKITA_FS_RMDIR_TARGET_ENOENT target does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/missing"
      .should.be.rejectedWith
        code: 'NIKITA_FS_RMDIR_TARGET_ENOENT'
        message: /NIKITA_FS_RMDIR_TARGET_ENOENT: fail to remove a directory, target is not a directory, got ".*\/missing"/
        exit_code: 2
        errno: -2
        syscall: 'rmdir'
        path: /.*\/missing/
