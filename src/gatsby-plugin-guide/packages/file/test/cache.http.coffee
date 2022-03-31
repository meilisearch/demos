
http = require 'http'
path = require 'path'
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.cache http', ->

  portincr = 22345
  server = ->
    _ = null
    port = portincr++
    srv =
      port: port
      listen: ->
        new Promise (resolve, reject) ->
          _ = http.createServer (req, res) ->
            switch req.url
              when '/my_file'
                res.writeHead 200, {'Content-Type': 'text/plain'}
                res.end 'okay'
              else
                res.writeHead 404, {'Content-Type': 'text/plain'}
                res.end 'Not found'
          _.listen port
          .on 'listening', -> resolve srv
          .on 'error', (err) -> reject err
      close: ->
        new Promise (resolve) ->
          _.close resolve
  
  they 'handles string argument', ({ssh}) ->
    try
      srv = await server().listen()
      await nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.cache "http://localhost:#{srv.port}/my_file",
          cache_dir: "#{tmpdir}/my_cache_dir"
        @fs.assert
          target: "#{tmpdir}/my_cache_dir/my_file"
    finally
      srv.close()
  
  they 'into local cache_dir', ({ssh}) ->
    try
      srv = await server().listen()
      await nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.cache
          source: "http://localhost:#{srv.port}/my_file"
          cache_dir: "#{tmpdir}/my_cache_dir"
        .should.be.finally.containEql $status: true
        @file.cache
          source: "http://localhost:#{srv.port}/my_file"
          cache_dir: "#{tmpdir}/my_cache_dir"
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/my_cache_dir/my_file"
    finally
      srv.close()

  they 'option fail with invalid exit code', ({ssh}) ->
    try
      srv = await server().listen()
      await nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.cache
          source: "http://localhost:#{srv.port}/missing"
          cache_dir: "#{tmpdir}/cache_dir_1"
        .should.be.finally.containEql $status: true
        @file.cache
          source: "http://localhost:#{srv.port}/missing"
          cache_dir: "#{tmpdir}/cache_dir_2"
          fail: true
        .should.be.rejectedWith exit_code: 22
    finally
      srv.close()

  describe 'hash', ->

    they 'current cache file matches provided hash', ({ssh}) ->
      try
        srv = await server().listen()
        await nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @log.fs
            basedir: tmpdir
            serializer: text: (log) -> "#{log.message}\n"
          @file
            target: "#{tmpdir}/my_cache_file"
            content: 'okay'
          @file.cache
            source: "http://localhost:#{srv.port}/my_file"
            cache_file: "#{tmpdir}/my_cache_file"
            md5: 'df8fede7ff71608e24a5576326e41c75'
          .should.be.finally.containEql $status: false
          {data} = await @fs.base.readFile
            target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
            encoding: 'utf8'
          (data.includes 'Hashes match, skipping').should.be.true()
      finally
        srv.close()

    they 'current cache file doesnt match provided hash', ({ssh}) ->
      try
        srv = await server().listen()
        await nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/my_cache_file"
            content: 'not okay'
          @file.cache
            source: "http://localhost:#{srv.port}/my_file"
            cache_file: "#{tmpdir}/my_cache_file"
            md5: 'df8fede7ff71608e24a5576326e41c75'
          .should.be.finally.containEql $status: true
      finally
        srv.close()

    they 'target file must match the hash', ({ssh}) ->
      try
        srv = await server().listen()
        await nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file.cache
            source: "http://localhost:#{srv.port}/missing"
            cache_dir: "#{tmpdir}/cache"
            md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
          .should.be.rejectedWith message: "NIKITA_FILE_INVALID_TARGET_HASH: target \"#{tmpdir}/cache/missing\" got 9e076f5885f5cc16a4b5aeb8de4adff5 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      finally
        srv.close()

    they 'md5', ({ssh}) ->
      try
        srv = await server().listen()
        await nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @log.fs
            basedir: tmpdir
            serializer: text: (log) -> "[#{log.level}] #{log.message}\n"
          @file
            target: "#{tmpdir}/source"
            content: "okay"
          @file
            target: "#{tmpdir}/target"
            content: "okay"
          # In http mode, md5 value will not be calculated from source
          @file.cache
            source: "http://localhost:#{srv.port}/my_file"
            cache_file: "#{tmpdir}/target"
            md5: true
          .should.be.finally.containEql $status: false
          {data} = await @fs.base.readFile
            target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
            encoding: 'utf8'
          (data.includes "[WARN] Bypass source hash computation for non-file protocols").should.be.true()
          @file.cache
            source: "http://localhost:#{srv.port}/my_file"
            cache_file: "#{tmpdir}/target"
            md5: 'df8fede7ff71608e24a5576326e41c75'
          .should.be.finally.containEql $status: false
          {data} = await @fs.base.readFile
            target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
            encoding: 'utf8'
          (data.includes "[DEBUG] Hashes match, skipping").should.be.true()
          @file.cache
            source: "http://localhost:#{srv.port}/my_file"
            cache_file: "#{tmpdir}/target"
            md5: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
          .should.be.rejectedWith message: "NIKITA_FILE_INVALID_TARGET_HASH: target \"#{tmpdir}/target\" got df8fede7ff71608e24a5576326e41c75 instead of xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      finally
        srv.close()
