
path = require 'path'
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.download file', ->
  
  describe 'source', ->

    they 'with file protocol', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          source: "file://#{__filename}"
          target: "#{tmpdir}/download_test" # Download a non existing file
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/download_test"
          content: /yeah/
        @file.download
          source: "file://#{__filename}"
          target: "#{tmpdir}/download_test" # Download on an existing file
        .should.be.finally.containEql $status: false

    they 'without protocol', ({ssh}) ->
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/download_test"
          content: /yeah/
        @file.download # Download on an existing file
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
        .should.be.finally.containEql $status: false

    they 'doesnt exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          source: "#{__dirname}/doesnotexists"
          target: "#{tmpdir}/download_test"
        .should.be.rejectedWith message: "NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got \"#{__dirname}/doesnotexists\""

    they 'into an existing directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/download_test"
        @file.download
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
        @fs.assert
          target: "#{tmpdir}/download_test/#{path.basename __filename}"

  describe 'cache', ->

    they 'validate md5', ({ssh}) ->
      source = "#{__dirname}/download.zip"
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          $ssh: ssh
          source: source
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
          md5: '3f104676a5f72de08b811dbb725244ff'
        .should.be.finally.containEql $status: true
        @fs.assert "#{tmpdir}/cache_dir/#{path.basename source}"

    they 'cache dir', ({ssh}) ->
      # Download a non existing file
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          $ssh: ssh
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: true
        @fs.assert "#{tmpdir}/cache_dir/#{path.basename __filename}"

    they 'detect file already present', ({ssh}) ->
      ssh = null
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.download
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        @file.download
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: false
        @file
          content: 'abc'
          target: "#{tmpdir}/download_test"
        @file.download
          source: "#{__filename}"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
        .should.be.finally.containEql $status: true
  
  describe 'md5', ->

    they 'cache dir with md5 string', ({ssh}) ->
      # Download a non existing file
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'okay'
        @file.download
          source: "#{tmpdir}/a_file"
          target: "#{tmpdir}/download_test"
          cache: true
          cache_dir: "#{tmpdir}/cache_dir"
          md5: 'df8fede7ff71608e24a5576326e41c75'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/cache_dir/a_file"
          content: 'okay'
        @fs.assert
          target: "#{tmpdir}/download_test"
          content: 'okay'

    they 'is computed if true', ({ssh}) ->
      # Download with invalid checksum
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "[#{log.level}] #{log.message}\n"
        @file
          target: "#{tmpdir}/source"
          content: "okay"
        @file.download
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/check_md5"
          md5: true
        .should.be.finally.containEql $status: true
        @file.download
          source: "#{tmpdir}/source"
          target: "#{tmpdir}/check_md5"
          md5: true
        .should.be.finally.containEql $status: false
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        (data.includes "[WARN] Hash dont match, source is 'df8fede7ff71608e24a5576326e41c75' and target is 'null'").should.be.true()
        (data.includes "[INFO] Hash matches as 'df8fede7ff71608e24a5576326e41c75'").should.be.true()
      
  describe 'error', ->

    they 'path must be absolute over ssh', ({ssh}) ->
      return unless ssh
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.touch
          target: "#{tmpdir}/a_file"
        @file.download
          source: "#{tmpdir}/a_file"
          target: "a_dir/download_test"
        .should.be.rejectedWith message: 'Non Absolute Path: target is "a_dir/download_test", SSH requires absolute paths, you must provide an absolute path in the target or the cwd option'
