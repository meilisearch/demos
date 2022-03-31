
fs = require 'fs'
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'log.csv', ->
  
  they 'write message', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.csv basedir: tmpdir
      await @call ({tools: {log}}) -> log 'ok'
      {data} = await @fs.base.readFile "#{tmpdir}/#{ssh?.host or 'local'}.log", encoding: 'ascii'
      data.should.eql 'text,INFO,"ok"\n'

  they 'write header', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.csv basedir: tmpdir
      await @call $header: 'h1', ({tools: {log}}) -> true
      {data} = await @fs.base.readFile "#{tmpdir}/#{ssh?.host or 'local'}.log", encoding: 'ascii'
      data.should.eql 'header,,"h1"\n'
    
