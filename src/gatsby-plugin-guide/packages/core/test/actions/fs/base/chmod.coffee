
nikita = require '../../../../src'
utils = require '../../../../src/utils'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

describe 'actions.fs.base.chmod', ->
  
  describe 'schema', ->
    return unless tags.api
    
    it 'absolute mode', ->
      nikita.fs.base.chmod
        mode: 0o1744
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 0o1744
    
    it 'symbolic mode', ->
      nikita.fs.base.chmod
        mode: 'u=rwx'
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 'u=rwx'
        
    it 'disable coersion from string to absolute mode', ->
      nikita.fs.base.chmod
        mode: '744'
        target: '/tmp/file'
      , ({config}) ->
        config.mode.should.eql 0o0744
  
  describe 'usage', ->
    return unless tags.posix

    they 'create', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.base.writeFile
          target: "{{parent.metadata.tmpdir}}/a_target"
          content: 'hello'
        await @fs.base.chmod
          mode: 0o600
          target: "{{parent.metadata.tmpdir}}/a_target"
        {stats} = await @fs.base.stat
          target: "{{parent.metadata.tmpdir}}/a_target"
        (stats.mode & 0o777).toString(8).should.eql '600'
