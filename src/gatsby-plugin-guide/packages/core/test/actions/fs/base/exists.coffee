
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.exists', ->
  
  they 'does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @fs.base.exists
        target: "#{tmpdir}/not_here"
      .should.be.finally.containEql
        exists: false
        target: "#{tmpdir}/not_here"

  they 'exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @fs.base.writeFile
        target: "#{tmpdir}/a_file"
        content: "some content"
      @fs.base.exists
        target: "#{tmpdir}/a_file"
      .should.be.finally.containEql
        exists: true
        target: "#{tmpdir}/a_file"

  they 'option argument default to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: ''
      @fs.base.exists "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql exists: true
