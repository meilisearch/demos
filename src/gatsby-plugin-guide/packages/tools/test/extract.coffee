
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'tools.extract', ->

  they 'should see extension .tgz', ({ssh}) ->
    # Test a non existing extracted dir
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
      $status.should.be.true()

  they 'should see extension .zip', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.zip"
        target: tmpdir
      $status.should.be.true()

  they 'should see extension .tar.bz2', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tar.bz2"
        target: tmpdir
      $status.should.be.true()

  they 'should see extension .tar.xz', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tar.xz"
        target: tmpdir
      $status.should.be.true()

  they 'with a created file and an invalid creates option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
        creates: "#{tmpdir}/oh_no"
      .should.be.rejectedWith
        code: 'NIKITA_FS_ASSERT_FILE_MISSING'

  they 'with a created file and a valid creates option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
        creates: "#{tmpdir}/a_dir"
      $status.should.be.true()

  they 'with `unless_exists`', ({ssh}) ->
    # Test with invalid creates option
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        $unless_exists: __dirname
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
      $status.should.be.false()

  they 'should pass error for invalid extension', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @tools.extract
        source: __filename
      .should.be.rejectedWith
        message: 'Unsupported extension, got ".coffee"'

  they 'should pass error for missing source file', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @tools.extract
        source: '/does/not/exist.tgz'
      .should.be.rejectedWith
        code: 'NIKITA_FS_STAT_TARGET_ENOENT'

  they 'should strip component level 1', ({ssh}) ->
    # Test a non existing status dir
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
        strip: 1
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_file"

  they 'should strip component level 2', ({ssh}) ->
    # Test a non existing extracted dir
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.extract
        source: "#{__dirname}/resources/a_dir.tgz"
        target: tmpdir
        strip: 2
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_file"
        not: true
  
