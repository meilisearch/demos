
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.wait', ->
  
  describe 'schema', ->
  
    it 'string argument converted to target', ->
      nikita.fs.wait '/path/to/file', ({config}) ->
        config.target.should.eql ['/path/to/file']
  
  describe 'usage', ->

    they 'status false if already exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @fs.wait
          target: "#{tmpdir}"
        $status.should.be.false()

    they 'status true if created', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        setTimeout ->
          nikita($ssh: ssh).fs.mkdir "#{tmpdir}/a_dir"
        , 200
        {$status} = await @fs.wait
          target: "#{tmpdir}/a_dir"
          interval: 50
        $status.should.be.true()
