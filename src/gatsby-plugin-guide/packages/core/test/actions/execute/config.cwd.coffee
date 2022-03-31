
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.cwd', ->
  return unless tags.system_execute_arc_chroot

  they 'execute in the context of directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stdout} = await @execute
        command: 'pwd'
        cwd: tmpdir
      stdout.should.eql "#{tmpdir}\n"
  
