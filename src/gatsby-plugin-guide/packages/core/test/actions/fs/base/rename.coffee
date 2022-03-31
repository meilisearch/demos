
nikita = require '../../../../src'
utils = require '../../../../src/utils'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.rename', ->

  they 'create', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'hello'
      await @fs.base.rename
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a_target"
      utils.stats.isFile(stats.mode).should.be.true()
