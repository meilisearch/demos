
http = require 'http'
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'network.tcp.wait', ->

  portincr = 22545
  server = ->
    port = portincr++
    srv =
      app: http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      port: port
      listen: ->
        new Promise (resolve) ->
          srv.listening = true
          srv.app.listen srv.port
          .on 'listening', -> resolve srv
          .on 'error', (err) -> reject err
      close: ->
        new Promise (resolve) ->
          srv.app.close resolve

  describe 'Schema and validation', ->

    it 'coercion port from integer', ->
      nikita.network.tcp.wait
        host: 'localhost'
        port: '80'
      , ({config}) ->
        config.server.should.eql [
          host: ['localhost']
          port: [80]
        ]

    it 'option server', ->
      {$logs} = await nikita.network.tcp.wait
        host: undefined
        port: 80
      $logs.map ({message}) -> message
      .should.containEql 'No connection to wait for'

    it 'option server.host undefined', ->
      {$logs} = await nikita.network.tcp.wait
        server: [
          { host: undefined, port: 80 }
        ]
      $logs.map ({message}) -> message
      .should.containEql 'No connection to wait for'

    it 'option server.port undefined', ->
      {$logs} = await nikita.network.tcp.wait
        server: [
          { host: 'localhost', port: undefined }
        ]
      $logs.map ({message}) -> message
      .should.containEql 'No connection to wait for'

  describe 'run', ->

    they 'a single host and a single port', ({ssh}) ->
      return if ssh
      srv = server()
      await nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        events.on 'stderr_stream', (log) ->
          if /Connection failed/.test log.message?.toString()
            srv.listen()
        {$status} = await @network.tcp.wait
          interval: 200
          host: 'localhost'
          port: srv.port
        $status.should.be.true()
      await srv.close()

    they 'server as an object `{host, [port]}`', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      await nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        events.on 'stderr_stream', (log) ->
          if /Connection failed/.test log.message?.toString()
            srv1.listen() unless srv1.listening
            srv2.listen() unless srv2.listening
        {$status} = await @network.tcp.wait
          interval: 200
          server: host: 'localhost', port: srv1.port
        $status.should.be.true()
        {$status} = await @network.tcp.wait
          interval: 200
          server: host: 'localhost', port: [srv1.port, srv2.port]
        $status.should.be.false()
      await srv1.close()
      await srv2.close()
      
    they 'server as an array `[{host, port}]`', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      await nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        events.on 'stderr_stream', (log) ->
          if /Connection failed/.test log.message?.toString()
            srv1.listen()
            srv2.listen()
        {$status} = await @network.tcp.wait
          interval: 200
          server: [
            [{host: 'localhost', port: srv1.port}]
            [{host: 'localhost', port: srv2.port}]
          ]
        $status.should.be.true()
      await srv1.close()
      await srv2.close()

    they 'server string `host:port`', ({ssh}) ->
      srv = server()
      await nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        events.on 'stderr_stream', (log) ->
          if /Connection failed/.test log.message?.toString()
            srv.listen()
        {$status} = await @network.tcp.wait
          interval: 200
          server: "localhost:#{srv.port}"
        $status.should.be.true()
      srv.close()

    they 'multiple connection', ({ssh}) ->
      srv = server()
      await nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        events.on 'stderr_stream', (log) ->
          if /Connection failed/.test log.message?.toString()
            srv.listen()
        {$status} = await @network.tcp.wait
          interval: 200
          server: for i in [0...12]
            {host: 'localhost', port: srv.port}
        $status.should.be.true()
      srv.close()

  describe 'status', ->

    they 'test status `false`', ({ssh}) ->
      try
        srv = server()
        await srv.listen()
        await nikita
          $ssh: ssh
        , ({tools: {events}}) ->
          {$status} = await @network.tcp.wait
            interval: 200
            host: 'localhost'
            port: srv.port
          $status.should.be.false()
      finally
        srv.close()
    
    they 'test status `true`', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        try
          srv = server()
          events.on 'stderr_stream', (log) ->
            if /Connection failed/.test log.message?.toString()
              srv.listen()
          {$status} = await @network.tcp.wait
            interval: 200
            host: 'localhost'
            port: srv.port
          $status.should.be.true()
        finally
          srv.close()

  describe 'config', ->

    they 'quorum true', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        try
          srv1 = server()
          srv2 = server()
          srv3 = server()
          events.on 'stderr_stream', (log) ->
            if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
              srv1.listen()
              srv2.listen()
          {$status} = await @network.tcp.wait
            server: [
              { host: 'localhost', port: srv1.port }
              { host: 'localhost', port: srv2.port }
              { host: 'localhost', port: srv3.port }
            ]
            quorum: true
            interval: 200
          $status.should.be.true()
        finally
          srv1.close()
          srv2.close()

    they 'quorum even number', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        try
          srv1 = server()
          srv2 = server()
          events.on 'stderr_stream', (log) ->
            if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
              srv1.listen()
          {$status} = await @network.tcp.wait
            interval: 200
            server: [
              { host: 'localhost', port: srv1.port }
              { host: 'localhost', port: srv2.port }
            ]
            quorum: 1
          $status.should.be.true()
        finally
          srv1.close()

    they 'quorum odd number', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({tools: {events}}) ->
        try
          srv1 = server()
          srv2 = server()
          srv3 = server()
          events.on 'stderr_stream', (log) ->
            if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
              srv1.listen()
              srv2.listen()
          {$status} = await @network.tcp.wait
            interval: 200
            server: [
              { host: 'localhost', port: srv1.port }
              { host: 'localhost', port: srv2.port }
              { host: 'localhost', port: srv3.port }
            ]
            quorum: 2
          $status.should.be.true()
        finally
          srv1.close()
          srv2.close()
