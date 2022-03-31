
path = require 'path'
os = require 'os'
fs = require 'ssh2-fs'
{tags, config} = require '../../test'
nikita = require '../../../src'
they = require('mocha-they')(config)

describe 'plugins.metadata.tmpdir', ->
  return unless tags.api
  
  describe 'validation', ->

    they 'invalid value', ({ssh}) ->
      nikita.call $ssh: ssh, $tmpdir: {}, (->)
      .should.be.rejectedWith
        code: 'METADATA_TMPDIR_INVALID'
        message: [
          'METADATA_TMPDIR_INVALID:'
          'the "tmpdir" metadata value must be a boolean, a function or a string,'
          "got {}"
        ].join ' '
  
  describe 'cascade', ->

    they 'not available in children', ({ssh}) ->
      nikita.call $ssh: ssh, $tmpdir: true, ->
        @call -> @call ({metadata: {tmpdir}}) ->
          should(tmpdir).be.undefined()

    they 'current action', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({ssh}) ->
        tmpdir = await @call
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          await fs.exists(ssh, tmpdir).should.be.resolvedWith true
          tmpdir
        fs.exists(ssh, tmpdir).should.be.resolvedWith false

    they 'remove directory with files and foders inside', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({ssh}) ->
        tmpdir = await @call
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          await fs.mkdir ssh, "#{tmpdir}/a_dir"
          await fs.writeFile ssh, "#{tmpdir}/a_dir/a_file", ''
          tmpdir
        fs.exists(ssh, tmpdir).should.be.resolvedWith false
  
  describe 'option tmpdir', ->

    they 'is a boolean', ({ssh}) ->
      nikita
        $ssh: ssh
      .call $tmpdir: true, ({metadata}) ->
        metadata.tmpdir
      .then (tmpdir) ->
        path.parse(tmpdir).name.should.match /^nikita-\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/

    they 'is a string', ({ssh}) ->
      nikita
        $ssh: ssh
      .call $tmpdir: './a_dir', ({metadata}) ->
        metadata.tmpdir
      .then (tmpdir) ->
        tmpdir.should.eql unless ssh
        then path.resolve os.tmpdir(), './a_dir'
        else path.posix.resolve '/tmp', './a_dir'

    they 'is a function', ({ssh}) ->
      nikita
        $ssh: ssh
      .call
        $tmpdir: ({action, os_tmpdir, tmpdir}) ->
          os_tmpdir.should.eql unless ssh
          then os.tmpdir()
          else '/tmp'
          tmpdir.should.match /^nikita-.*/
          # Test action arg and return
          action.tools.path.join os_tmpdir, "#{tmpdir}-ok"
      , ({metadata}) -> metadata.tmpdir
      .then (tmpdir) ->
        tmpdir.should.match /ok$/
          
    they 'ssh and tmpdir in same child', -> ({ssh}) ->
      # Fix bug where the ssh connection was not discoved when
      # ssh was created in the same child and tmpdir
      nikita.call $ssh: ssh, $tmpdir: true, (->)
      .should.be.resolved()

  describe 'option dirty', ->

    they 'is true', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
      , ->
        try
          @call $tmpdir: true, $dirty: true, (->)
          {exists} = await @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
          exists.should.be.true()
        finally
          @fs.base.rmdir '{{siblings.0.metadata.tmpdir}}'

    they 'is false', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
      , ->
        @call $tmpdir: true, $dirty: false, (->)
        @fs.base.exists '{{siblings.0.metadata.tmpdir}}'
        .should.finally.match exists: false
