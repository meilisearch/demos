
nikita = require '../../../../src'
fs = require('fs').promises
{Dirent} = require 'fs'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.readdir', ->
  
  it 'get native behavior', ->
    nikita
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await fs.mkdir "#{tmpdir}/parent"
      await fs.mkdir "#{tmpdir}/parent/a_dir"
      await fs.writeFile "#{tmpdir}/parent/file_1", ''
      await fs.writeFile "#{tmpdir}/parent/file_2", ''
      # No options
      files = await fs.readdir "#{tmpdir}/parent"
      files.should.eql ['a_dir', 'file_1', 'file_2']
      # Option `withFileTypes`
      files = await fs.readdir "#{tmpdir}/parent", withFileTypes: true
      files
      .sort()
      .map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
      .should.eql [
        { name: 'a_dir' }
        { name: 'file_1' }
        { name: 'file_2' }
      ]
      files[0].isDirectory().should.be.true()
      files[1].isFile().should.be.true()

  they 'target option as argument', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent"
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent/a_dir"
      await @fs.base.writeFile "{{parent.metadata.tmpdir}}/parent/file_1", content: 'hello'
      await @fs.base.writeFile "{{parent.metadata.tmpdir}}/parent/file_2", content: 'hello'
      @fs.base.readdir "{{parent.metadata.tmpdir}}/parent"
      .then ({files}) ->
        files.sort().should.eql ['a_dir', 'file_1', 'file_2']

  they 'target does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.base.readdir "{{parent.metadata.tmpdir}}/missing"
      .should.be.rejectedWith
        code: 'NIKITA_FS_READDIR_TARGET_ENOENT'
        message: /NIKITA_FS_READDIR_TARGET_ENOENT: fail to read a directory, target is not a directory, got ".*\/missing"/

  they 'handle missing file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent"
      await @fs.base.mkdir "{{parent.metadata.tmpdir}}/parent/a_dir"
      await @fs.base.writeFile "{{parent.metadata.tmpdir}}/parent/file_1", content: 'hello'
      await @fs.base.writeFile "{{parent.metadata.tmpdir}}/parent/file_2", content: 'hello'
      @fs.base.readdir "{{parent.metadata.tmpdir}}/parent", withFileTypes: true
      .then ({files}) ->
        files = files.sort()
        files.map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
        .should.eql [
          { name: 'a_dir' }
          { name: 'file_1' }
          { name: 'file_2' }
        ]
        files[0].isDirectory().should.be.true()
        files[1].isFile().should.be.true()
