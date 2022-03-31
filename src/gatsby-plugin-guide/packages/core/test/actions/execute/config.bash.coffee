
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.bash', ->
  return unless tags.posix

  they 'in generated path', ({ssh}) ->
    nikita
      $ssh: ssh
    .execute
      command: "echo $BASH"
      bash: true
    .then ({stdout}) ->
      stdout.should.containEql 'bash'

  they 'in user path', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {stdout} = await @execute
        command: "echo $BASH"
        bash: true
        dirty: true
        target: "#{tmpdir}/my_script"
      stdout.should.containEql 'bash'

  they 'option `dirty` is `true`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {stdout} = await @execute
        command: "echo $BASH"
        bash: true
        dirty: true
        target: "#{tmpdir}/my_script"
      {files} = await @fs.glob "#{tmpdir}/*"
      files.length.should.eql 1
      await @fs.assert
        target: files[0]
        content: 'echo $BASH'

    they 'option `dirty` is `false`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
      {stdout} = await @execute
        command: "echo $BASH"
        bash: true
        dirty: false
        target: "#{tmpdir}/my_script"
      {files} = await @fs.glob "#{tmpdir}/*"
      files.length.should.eql 0

  they 'option `code_skipped`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @execute
        command: "exit 2"
        bash: true
        code_skipped: 2
      $status.should.be.false()
