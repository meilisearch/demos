
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.sudo', ->
  return unless tags.sudo

  they 'execute.assert', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @execute.assert
        command: 'whoami'
        content: 'root'
        $sudo: true
        trim: true

  they 'readFile without sudo', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: false
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
        $sudo: true
      await @fs.base.chown
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
        $sudo: true
      await @fs.base.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o600
        $sudo: true
      # Note, we are testing EACCESS error because it is impossible to do it
      # without sudo inside fs.readFile
      @fs.base.readFile
        target: "#{tmpdir}/a_file"
        encoding: 'ascii'
      .should.be.rejectedWith
        message: "NIKITA_FS_CRS_TARGET_EACCES: fail to read a file because permission was denied, location is \"#{tmpdir}/a_file\"."
        errno: -13
        code: 'NIKITA_FS_CRS_TARGET_EACCES'
        syscall: 'open'
        path: "#{tmpdir}/a_file"

  they 'readFile with sudo', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: false
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
        $sudo: true
      @fs.base.chown
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
        $sudo: true
      @fs.base.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o600
        $sudo: true
      @fs.base.readFile
        target: "#{tmpdir}/a_file"
        encoding: 'ascii'
        $sudo: true
      .should.be.finally.containEql data: 'hello'

  they 'writeFile', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: '/tmp/nikita'
    , ({metadata: {tmpdir}})->
      await @fs.base.mkdir
        target: "#{tmpdir}/a_dir"
      await @fs.base.chown
        target: "#{tmpdir}/a_dir"
        uid: 0
        gid: 0
        $sudo: true
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
        $sudo: true
      @fs.base.readFile
        target: "#{tmpdir}/a_dir/a_file"
        encoding: 'ascii'
        $sudo: true
      .should.resolvedWith data: 'some content'
      @fs.base.unlink
        target: "#{tmpdir}/a_dir/a_file"
        $sudo: true
      @fs.base.rmdir
        target: "#{tmpdir}/a_dir"
        $sudo: true
    
