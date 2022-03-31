
http = require 'http'
{merge} = require 'mixme'
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

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
            when '/'
              res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
              res.end '{"key": "value"}'
            when '/ping'
              body = ''
              req.on 'data', (chunk) ->
                body += chunk.toString()
              req.on 'end', () ->
                res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
                res.end body
            when '/request_404'
              res.writeHead 404, 'Not found'
              res.end()
            when '/request_301'
              res.writeHead 301, 'Moved Permanently',
                'Server': 'Apache/2.4.6 (CentOS) mod_auth_gssapi/1.5.1 mod_nss/1.0.14 NSS/3.28.4 mod_wsgi/3.4 Python/2.7.5'
                'X-Frame-Options': 'DENY'
                'Content-Security-Policy': 'frame-ancestors \'none\''
                'Location': 'http://ipa.nikita/ipa/session/json'
                'Cache-Control': 'no-cache'
                'Set-Cookie': 'ipa_session=;Max-Age=0;path=/ipa;httponly;secure;'
                'Content-Length': 241
                'Content-Type': 'text/html; charset=iso-8859-1'
              res.end """
              <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
              <html><head>
              <title>301 Moved Permanently</title>
              </head><body>
              <h1>Moved Permanently</h1>
              <p>The document has moved <a href="http://ipa.nikita/ipa/session/json">here</a>.</p>
              </body></html>
              """
            when '/follow_redirect_1'
              res.writeHead 301, 'Moved Permanently',
                'Location': "http://localhost:#{port}/follow_redirect_2"
              res.end()
            when '/follow_redirect_2'
              res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
              res.end '{"key": "value"}'
            when '/content_type_with_charset'
              res.writeHead 200, 'OK', {'Content-Type': 'application/json; charset=utf-8'}
              res.end '{"key": "value"}'
        _.listen port
        .on 'listening', -> resolve srv
        .on 'error', (err) -> reject err
    close: ->
      new Promise (resolve) ->
        _.close resolve

describe 'network.http', ->

  describe 'usage', ->

    they 'a simple json GET', ({ssh}) ->
      try
        srv = await server().listen()
        {
          body, data, headers,
          status_code, status_message, type
        } = await nikita.network.http
          $ssh: ssh
          url: "http://localhost:#{srv.port}"
        status_code.should.eql 200
        status_message.should.eql 'OK'
        body.should.eql '{"key": "value"}'
        data.should.eql { key: 'value' }
        headers['Content-Type'].should.eql 'application/json'
        type.should.eql 'json'
      finally
        srv?.close()

    they 'escape single and double quotes', ({ssh}) ->
      try
        srv = await server().listen()
        {
          body, data, headers,
          status_code, status_message, type
        } = await nikita.network.http
          $ssh: ssh
          url: "http://localhost:#{srv.port}/ping"
          data:
            'te\'st': 'va\'lue'
            'te"st': 'va"lue'
        status_code.should.eql 200
        status_message.should.eql 'OK'
        body.should.eql '{"te\'st":"va\'lue","te\\"st":"va\\"lue"}'
        data.should.eql { 'te\'st': 'va\'lue', 'te"st': 'va"lue' }
        headers['Content-Type'].should.eql 'application/json'
        type.should.eql 'json'
      finally
        await srv?.close()
    
    they 'honors curl exit code', ({ssh}) ->
      nikita.network.http
        $ssh: ssh
        url: "http://2222:localhost"
      .should.be.rejectedWith
        code: 'CURLE_URL_MALFORMAT'
        message: 'CURLE_URL_MALFORMAT: the curl command exited with code `3`.'

  describe 'options', ->

    they 'option location (follow redirect)', ({ssh}) ->
      try
        srv = await server().listen()
        {status_code, data} = await nikita.network.http
          location: true
          $ssh: ssh
          url: "http://localhost:#{srv.port}/follow_redirect_1"
        status_code.should.eql 200
        data.should.eql key: 'value'
      finally
        await srv?.close()
  
  describe 'response', ->

    they 'code 404', ({ssh}) ->
      try
        srv = await server().listen()
        output = await nikita.network.http
          $ssh: ssh
          url: "http://localhost:#{srv.port}/request_404"
        output = merge output, raw: null, logs: [], headers: Date: null
        output.should.match
          $logs: []
          $status: true
          body: ''
          data: undefined
          headers:
            'Date': null
            'Connection': 'keep-alive'
            'Transfer-Encoding': 'chunked'
          http_version: '1.1'
          raw: null
          status_code: 404
          status_message: 'Not found'
          type: undefined
      finally
        srv?.close()

    they 'code 301 from ipa', ({ssh}) ->
      try
        srv = await server().listen()
        {status_code} = await nikita.network.http
          $ssh: ssh
          url: "http://localhost:#{srv.port}/request_301"
        status_code.should.eql 301
      finally
        srv?.close()

    they 'content type with charset', ({ssh}) ->
      try
        srv = await server().listen()
        {status_code, data, headers} = await nikita.network.http
          $ssh: ssh
          location: true
          url: "http://localhost:#{srv.port}/content_type_with_charset"
        headers['Content-Type'].should.eql 'application/json; charset=utf-8'
        status_code.should.eql 200
        data.should.eql key: 'value'
      finally
        srv?.close()
