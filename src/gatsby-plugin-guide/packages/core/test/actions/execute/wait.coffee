
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.wait', ->
  return unless tags.posix

  they 'single command, status false', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @execute.wait
        command: "test -d #{tmpdir}"
      $status.should.be.false()
  
  they 'single command, status true', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call ->
        setTimeout ->
          nikita($ssh: ssh?.config).fs.mkdir "#{tmpdir}/a_file"
        , 100
      {$status} = await @execute.wait
        command: "test -d #{tmpdir}/a_file"
        interval: 60
      $status.should.be.true()

  they 'take multiple commands', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @execute.wait
        command: [
          "test -d #{tmpdir}"
          "test -d #{tmpdir}"
        ]
      $status.should.be.false()
      @call ->
        setTimeout ->
          nikita($ssh: ssh?.config)
          .fs.mkdir "#{tmpdir}/file_1"
          .fs.mkdir "#{tmpdir}/file_2"
        , 100
      {$status} = await @execute.wait
        command: [
          "test -d #{tmpdir}/file_1"
          "test -d #{tmpdir}/file_2"
        ]
        interval: 40
      $status.should.be.true()

  describe 'logs', ->

    they 'attemps', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call ->
          setTimeout ->
            nikita($ssh: ssh?.config).fs.mkdir "#{tmpdir}/a_file"
          , 200
        {$logs} = await @execute.wait
          command: "test -d #{tmpdir}/a_file"
          interval: 100
        $logs
        .filter (log) -> /Attempt #\d/.test log.message
        .length.should.be.within 2, 8

    they 'honors *_log as true', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        logs = 0
        await @execute.wait
          command: "echo stdout; echo stderr >&2"
          stdin_log: true
          stdout_log: true
          stderr_log: true
          $log: ({log}) ->
            logs++ if log.type in ['stdin', 'stdout', 'stderr']
        logs.should.eql 3

    they 'honors *_log as false', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        logs = 0
        await @execute.wait
          command: "echo stdout; echo stderr >&2"
          stdin_log: false
          stdout_log: false
          stderr_log: false
          $log: ({log}) ->
            logs++ if log.type in ['stdin', 'stdout', 'stderr']
        logs.should.eql 0
  
  describe 'config `code_skipped`', ->
  
    they 'error if error code not skipped, first attempt', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @execute.wait
          command: "exit 99"
          code_skipped: 1
          interval: 40
        .should.be.rejectedWith
          code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'
          exit_code: 99
    
    they 'error if error code not skipped, retried attempt', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call ->
          setTimeout ->
            nikita($ssh: ssh?.config).fs.mkdir "#{tmpdir}/file"
          , 200
        @execute.wait
          command: "test -d #{tmpdir}/file && exit 99"
          code_skipped: 1
          interval: 40
        .should.be.rejectedWith
          code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'
          exit_code: 99

  describe 'config `quorum`', ->
    
    it 'boolean `true` is converted to quorum', ->
      # Odd number
      quorum = await nikita.execute.wait
        quorum: true
        command: ['echo 1', 'echo 2', 'echo 3']
      , ({config}) -> config.quorum
      quorum.should.eql 2
      # Even number
      quorum = await nikita.execute.wait
        quorum: true
        command: ['echo 1', 'echo 2', 'echo 3', 'echo 4']
      , ({config}) -> config.quorum
      quorum.should.eql 3

    they 'all commands succeed when not defined', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir, uuid}}) ->
        @call -> setImmediate ->
          nikita
            $ssh: ssh?.config
          .wait 200
          .fs.mkdir "#{tmpdir}/file_1"
          .wait 200
          .fs.mkdir "#{tmpdir}/file_2"
          .wait 200
          .fs.mkdir "#{tmpdir}/file_3"
        {attempts, $status} = await @execute.wait
          command: [
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_3 && echo 3 >> #{tmpdir}/result"
          ]
          interval: 100
        attempts.should.be.above 2
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n3\n'

    they 'is a number', ({ssh}) ->
      @timeout 20000
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call -> setImmediate ->
          nikita
            $ssh: ssh?.config
          .wait 200
          .fs.mkdir "#{tmpdir}/file_1"
          .wait 200
          .fs.mkdir "#{tmpdir}/file_2"
        {$status} = await @execute.wait
          command: [
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
          ]
          interval: 40
          quorum: 2
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n'

    they 'with failing commands', ({ssh}) ->
      @timeout 20000
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call -> setImmediate ->
          nikita
            $ssh: ssh?.config
          .wait 200
          .fs.mkdir "#{tmpdir}/file_1"
          .wait 200
          .fs.mkdir "#{tmpdir}/file_2"
        {$status} = await @execute.wait
          command: [
            'exit 99'
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            'exit 99'
            'exit 0' # Reach quorum 3
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
          ]
          interval: 50
          quorum: true
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n'
  
  describe 'option `retry`', ->
    
    they 'when `0`, not execution', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        try
          await @execute.wait
            command: "test -d #{tmpdir}/a_file"
            interval: 100
            retry: 3
        catch err
          err.code.should.eql 'NIKITA_EXECUTE_WAIT_MAX_RETRY'
          err.$logs
          .filter (log) -> /Attempt #\d/.test log.message
          .length.should.eql 3
