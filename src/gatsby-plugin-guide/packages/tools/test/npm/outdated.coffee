
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_npm

describe 'tools.npm.outdated', ->

  they 'option `cwd`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.npm.uninstall
        name: 'csv-parse@'
        cwd: tmpdir
      @tools.npm
        name: 'csv-parse@3.0.0'
        cwd: tmpdir
      {packages} = await @tools.npm.outdated
        cwd: tmpdir
      {current, wanted} = packages['csv-parse']
      current.should.eql '3.0.0'
      current.should.not.eql wanted

  they 'option `global`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @tools.npm.uninstall
        name: 'csv-parse'
        global: true
      @tools.npm
        name: 'csv-parse@3.0.0'
        global: true
      {packages} = await @tools.npm.outdated
        global: true
      {current, wanted} = packages['csv-parse']
      current.should.eql '3.0.0'
      current.should.not.eql wanted
