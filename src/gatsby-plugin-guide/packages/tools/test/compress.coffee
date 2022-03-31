
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'tools.compress', ->

  they 'should see extension .tgz', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir/a_file"
        target: "#{tmpdir}/a_dir.tgz"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir.tgz"

  they 'should see extension .zip', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir/a_file"
        target: "#{tmpdir}/a_dir.zip"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir.zip"

  they 'should see extension .tar.bz2', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir/a_file"
        target: "#{tmpdir}/a_dir.tar.bz2"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir.tar.bz2"

  they 'should see extension .tar.xz', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir/a_file"
        target: "#{tmpdir}/a_dir.tar.xz"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir.tar.xz"
  
  they 'remove source file with clean option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'hello'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir/a_file"
        target: "#{tmpdir}/a_dir.tar.xz"
        clean: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir/a_file"
        not: true
  
  they 'remove source directory with clean option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/a_dir/a_file"
        content: 'hello'
      {$status} = await @tools.compress
        source: "#{tmpdir}/a_dir"
        target: "#{tmpdir}/a_dir.tar.xz"
        clean: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_dir"
        not: true

  they 'should pass error for invalid extension', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.compress
        source: __filename
        target: __filename
      .should.be.rejectedWith
        message: 'Unsupported Extension: ".coffee"'
