
nikita = require '../../../../src'
utils = require '../../../../src/utils'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.stat', ->

  they 'NIKITA_FS_STAT_TARGET_ENOENT target does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/not_here"
      .should.be.rejectedWith
        code: 'NIKITA_FS_STAT_TARGET_ENOENT'
        message: /NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got ".*"/

  they 'with a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a_file"
      utils.stats.isFile(stats.mode).should.be.true()
      stats.mode.should.be.a.Number()
      stats.uid.should.be.a.Number()
      stats.gid.should.be.a.Number()
      stats.size.should.be.a.Number()
      stats.atime.should.be.a.Number()
      stats.mtime.should.be.a.Number()
  
  they 'with a file containing a space', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a file"
        content: 'hello'
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a file"
      utils.stats.isFile(stats.mode).should.be.true()
      stats.mode.should.be.a.Number()
      stats.uid.should.be.a.Number()
      stats.gid.should.be.a.Number()
      stats.size.should.be.a.Number()
      stats.atime.should.be.a.Number()
      stats.mtime.should.be.a.Number()

  they 'with a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a_dir"
      utils.stats.isDirectory(stats.mode).should.be.true()

  they 'with a file link', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      @fs.base.symlink
        target: "{{parent.metadata.tmpdir}}/a_link"
        source: "{{parent.metadata.tmpdir}}/a_file"
      {stats} = await @fs.base.lstat
        target: "{{parent.metadata.tmpdir}}/a_link"
      utils.stats.isFile(stats.mode).should.be.false()
      utils.stats.isSymbolicLink(stats.mode).should.be.true()

  they 'with a directory link', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      @fs.base.symlink
        target: "{{parent.metadata.tmpdir}}/a_link"
        source: "{{parent.metadata.tmpdir}}/a_dir"
      {stats} = await @fs.base.lstat
        target: "{{parent.metadata.tmpdir}}/a_link"
      utils.stats.isDirectory(stats.mode).should.be.false()
      utils.stats.isSymbolicLink(stats.mode).should.be.true()
