
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'system.running', ->

  they 'pid not running', ({ssh}) ->
    {$logs, running} = await nikita({ssh: ssh}).system.running
      pid: 9999999
    running.should.be.false()
    $logs
    .map( ({message}) -> message)
    .should.matchAny "PID 9999999 is not running"
  
  they 'pid running', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout} = await @execute
        command: """
        bash -c "while true ; do sleep 1; done" >/dev/null 2>&1 &
        echo $!
        """
      pid = stdout.trim().split(' ').pop()
      try
        {$logs, running} = await @system.running
          pid: pid
        running.should.be.true()
        $logs
        .map( ({message}) -> message)
        .should.matchAny "PID #{pid} is running"
      finally
        await @execute "kill #{pid}"
        
  they 'pid file does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$logs, running} = await @system.running
        target: "#{tmpdir}/pid.lock"
      running.should.be.false()
      $logs
      .map( ({message}) -> message)
      .should.matchAny "PID file #{tmpdir}/pid.lock does not exists"
        
  they 'pid file not running', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @file
        target: "#{tmpdir}/pid.lock"
        content: '9999999'
      {$logs, running} = await @system.running
        target: "#{tmpdir}/pid.lock"
      running.should.be.false()
      $logs
      .map( ({message}) -> message)
      .should.matchAny "PID 9999999 is not running"
        
  they 'pid file running', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      try
        {stdout} = await @execute
          command: """
          bash -c "while true ; do sleep 1; done" >/dev/null 2>&1 &
          PID=`echo $!`
          echo $PID > #{tmpdir}/pid.lock
          echo $PID
          """
        pid = stdout.trim().split(' ').pop()
        {$logs, running} = await @system.running
          target: "#{tmpdir}/pid.lock"
        running.should.be.true()
        $logs
        .map( ({message}) -> message)
        .should.matchAny "PID #{pid} is running"
      finally
        await @execute "kill `cat #{tmpdir}/pid.lock`"
