
stream = require 'stream'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute', ->
  return unless tags.posix

  describe 'config `command`', ->

    they 'as a string', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: 'text=yes; echo $text'
        .should.be.finally.containEql
          $status: true
          stdout: 'yes\n'

    they 'as an argument', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @execute 'text=yes; echo $text'
        .should.be.finally.containEql
          $status: true
          stdout: 'yes\n'

    they 'as an action handler returning a string', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          a_key: 'test context'
          command: ({config}) ->
            "text='#{config.a_key}'; echo $text"
        .should.be.finally.containEql
          stdout: 'test context\n'

    they 'as an action handler returning a promise', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          a_key: 'test context'
          command: ({config}) ->
            new Promise (resolve, reject) ->
              resolve "text='#{config.a_key}'; echo $text"
        .should.be.finally.containEql
          stdout: 'test context\n'

  describe 'stream', ->

    they 'stdout and unpipe', ({ssh}) ->
      writer_done = callback_done = null
      data = ''
      out = new stream.Writable
      out._write = (chunk, encoding, callback) ->
        data += chunk.toString()
        callback()
      search1 = 'search_toto'
      search2 = 'search_lulu'
      unpiped = 0
      out.on 'unpipe', ->
        unpiped++
      out.on 'finish', ->
        false.should.be.true()
      await nikita
        $ssh: ssh
      , (->)
      .execute
        command: "cat #{__filename} | grep #{search1}"
        stdout: out
      .execute
        command: "cat #{__filename} | grep #{search2}"
        stdout: out
      unpiped.should.eql 2
      data.should.containEql search1
      data.should.containEql search2

    they 'stdout and stderr return empty on command error', ({ssh}) -> #.skip 'remote',
      nikita
        $ssh: ssh
      .execute
        command: "echo 'some text' | grep nothing"
        code: 1
      .should.be.finally.containEql
        stdout: ''
        stderr: ''

  describe 'code', ->

    they 'valid exit code', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: "exit 42"
          code: [42, 43]
        .should.be.resolved()

    they 'invalid exit code with default', ({ssh}) ->
      nikita.execute
        command: "exit 42"
        $ssh: ssh
      .should.be.rejectedWith [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42",'
        'got 42 instead of 0.'
      ].join ' '

    they 'invalid exit code unmatching provided codes', ({ssh}) ->
      nikita.execute
        command: "exit 42"
        code: [1,2,3]
        $ssh: ssh
      .should.be.rejectedWith [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42",'
        'got 42 while expecting one of [1,2,3].'
      ].join ' '

    they 'should honor code skipped', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: "exit 42"
          code_skipped: 42
        .should.be.finally.containEql $status: false
        @execute
          command: "exit 42"
          code_skipped: [42,43]
        .should.be.finally.containEql $status: false
    
    they 'log error', ({ssh}) ->
      logs = []
      nikita $ssh: ssh, ->
        @execute
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log
          command: "exit 1"
        .then -> throw Error 'Oh no'
        .catch ->
          logs.should.match [
            level: 'ERROR'
            message: 'An unexpected exit code was encountered, got `1`'
          ]
      
    they 'log error with metadata.relax', ({ssh}) ->
      logs = []
      nikita $ssh: ssh, ->
        @execute
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log
          $relax: true
          command: "exit 1"
        .then -> throw Error 'Oh no'
        .catch ->
          logs.should.match [
            level: 'INFO'
            message: 'An unexpected exit code was encountered in relax mode, got `1`'
          ]

  describe 'trim', ->

    they 'both stdout and stderr', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: """
          echo '  bonjour  '
          echo ' monde  ' >&2
          """
          trim: true
        .should.be.finally.containEql
          stdout: 'bonjour'
          stderr: 'monde'

    they 'with trim_stdout and trim_stderr', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: """
          echo '  bonjour  '
          echo ' monde  ' >&2
          """
          stdout_trim: true
          stderr_trim: true
        .should.be.finally.containEql
          stdout: 'bonjour'
          stderr: 'monde'

  describe 'log', ->

    they.skip 'stdin, stdout, stderr', ({ssh}) ->
      stdin = stdout = stderr = undefined
      nikita
        $ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stderr', (log) -> stderr = log
      .execute
        command: "echo 'to stderr' >&2; echo 'to stdout';"
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        stdout.message.should.eql 'to stdout\n'
        stderr.message.should.eql 'to stderr\n'

    they.skip 'disable logging', ({ssh}) ->
      stdin = stdout = stderr = undefined
      stdout_stream = stderr_stream = []
      nikita
        $ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stdout_stream', (log) -> stdout_stream.push log
      .on 'stderr', (log) -> stderr = log
      .on 'stderr_stream', (log) -> stderr_stream.push log
      .execute
        command: "echo 'to stderr' >&2; echo 'to stdout';"
        stdout_log: false
        stderr_log: false
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0

  describe 'trap', ->

    they 'trap on error', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: """
          sh -c '>&2 echo "exit 2'
          echo 'ok'
          """
        @execute
          command: """
          sh -c '>&2 echo "exit 2'
          echo 'ok'
          """
          trap: true
        .should.be.rejected()

  describe 'error', ->

    they 'provide `stdout` and `stderr`', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: """
          sh -c '>&2 echo "Some Error"; exit 2'
          """
        .should.be.rejectedWith
          code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'
          message: [
            'NIKITA_EXECUTE_EXIT_CODE_INVALID: an unexpected exit code was encountered,'
            'command is "sh -c \'>&2 echo \\"Some Error\\"; exit 2\'",'
            'got 2 instead of 0.'
          ].join ' '
          command: 'sh -c \'>&2 echo "Some Error"; exit 2\''
          exit_code: 2
          stdout: ''
          stderr: 'Some Error\n'
          $status: false

  describe 'dry', ->
    
    they 'dont execute the command', ({ssh}) ->
      res = await nikita.execute
        command: "exit 1"
        dry: true
      res.should.match
        stdout: []
        stderr: []
        code: null
        $status: false
        $logs: (it) -> it.should.be.an.Array()
