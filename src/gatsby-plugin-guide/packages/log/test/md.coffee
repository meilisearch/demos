
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'log.md', ->
  
  they 'write entering message', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.md basedir: tmpdir
      await @fs.assert
        target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
        content: /^Entering.*$/mg

  they 'write message', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.md basedir: tmpdir
      @call ({tools: {log}})->
        log message: 'ok'
      @fs.assert
        trim: true
        filter: [
          /^Entering.*$/mg
        ]
        target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
        content: 'ok'
  
  they 'write message and module', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @log.md basedir: tmpdir
      @call ({tools: {log}}) ->
        log message: 'ok', module: 'nikita/test/log/md'
      @fs.assert
        trim: true
        filter: [
          /^Entering.*$/mg
        ]
        target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
        content: 'ok (1.INFO, written by nikita/test/log/md)'

  describe 'config `serializer`', ->
    
    they 'custom nikita:action:start', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md
          basedir: tmpdir
          enter: false
          serializer:
            'nikita:action:start': ({action: {metadata}}) ->
              return unless metadata.header
              "#{metadata.position.join('.')} #{metadata.header}\n"
        @call $header: 'h1', ->
          @call $header: 'h2', (->)
        @call $header: 'h1', ->
          @call $header: 'h2', (->)
        @fs.assert
          trim: true
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          content: """
          0.1 h1
          0.1.0 h2
          0.2 h1
          0.2.0 h2
          """

  describe 'metadata `header`', ->
  
    they 'header before entering message', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call $header: 'header', () -> true
        @fs.assert
          trim: true
          filter: [
            /^Entering.*fs\/assert.*$/mg
          ]
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          content: /^# header\n\nEntering.*actions\/call.*$/
          
    they 'honors header', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call $header: 'h1', ({tools: {log}}) ->
          log message: 'ok 1'
          await @call ->
            new Promise (resolve) ->
              setTimeout resolve 200
          @call $header: 'h2', ({tools: {log}}) ->
            log message: 'ok 2'
        @fs.assert
          trim: true
          filter: [
            /^Entering.*$/mg
            /^\n$/mg
          ]
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          content: """
          # h1
          
          ok 1
          
          ## h1 : h2
          
          ok 2
          """
      
    they 'honors header', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call $header: 'h1', ->
          @call $header: 'h2', ({tools: {log}}) ->
            log message: 'ok 2'
        @fs.assert
          trim: true
          filter: [
            /^Entering.*$/mg
            /^\n$/mg
          ]
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          content: """
          # h1
          
          ## h1 : h2
          
          ok 2
          """

  describe 'execute', ->
    
    they 'honors stdout_stream', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a one line output'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        data.should.containEql """
          ```stdout
          this is a one line output
          
          ```
          """
          
    they 'stdin one line', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a first line'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        data.should.containEql """
          Running Command: `echo 'this is a first line'`
          """
          
    they 'stdin multi line', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a first line'
        echo 'this is a second line'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'utf8'
        data.should.containEql """
          ```stdin
          echo 'this is a first line'
          echo 'this is a second line'
          ```
          """
  
  describe 'event `diff`', ->
    
    they 'write message in code block', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.md basedir: tmpdir, enter: false
        await @call ({tools: {log}}) ->
          log message: '1 + new line', type: 'diff'
        @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'ascii'
        .should.be.resolvedWith
          data: '\n```diff\n1 + new line```\n'
      
  
  describe 'config `enter`', ->
            
    they 'disabled when false', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.md basedir: tmpdir, enter: false
        await @call (->)
        await @call (->)
        @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'ascii'
        .should.be.resolvedWith
          data: ''
    
    they 'disabled with $log', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.md basedir: tmpdir
        await @call $log: false, (->)
        await @call (->)
        await @call $log: false, (->)
        @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'ascii'
        .should.be.resolvedWith
          data: "\nEntering @nikitajs/core/lib/actions/call (1.3)\n"
    
    they 'filtered out for bastards action', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @log.md basedir: tmpdir
        await @call
          $unless_exists: "#{tmpdir}/toto"
          $if: -> @call -> false
        , (->)
        @fs.base.readFile
          target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
          encoding: 'ascii'
        .should.be.resolvedWith
          data: "\nEntering @nikitajs/core/lib/actions/call (1.2)\n"
