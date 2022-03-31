
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_npm

describe 'tools.npm.upgrade', ->

  describe 'schema', ->

    it 'cwd or global is true are required', ->
      nikita.tools.npm.upgrade {}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `tools.npm.upgrade`:'
          '#/if config must match "then" schema, failingKeyword is "then";'
          '#/then/required config must have required property \'cwd\'.'
        ].join ' '
    
    it 'global is `true`', ->
      nikita.tools.npm.upgrade
        global: true
      , (->)

  describe 'action', ->

    they 'upgrade packages locally', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: 'csv-parse@3.0.0'
        {$status} = await @tools.npm.upgrade
          cwd: tmpdir
        $status.should.be.true()
        {$status} = await @tools.npm.upgrade
          cwd: tmpdir
        $status.should.be.false()
        {packages} = await @tools.npm.list
          cwd: tmpdir
        # local updates follow caret versioning and only update minor versions
        [major] = packages['csv-parse'].version.split('.')
        major.should.be.equal '3'

    they 'upgrade packages globally', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @tools.npm.uninstall
          name: 'csv-parse'
          global: true
        {$status} = await @tools.npm
          name: 'csv-parse@3.0.0'
          global: true
        {$status} = await @tools.npm.upgrade
          global: true
        $status.should.be.true()
        {$status} = await @tools.npm.upgrade
          global: true
        $status.should.be.false()
        {packages} = await @tools.npm.list
          global: true
        # global updates update major versions
        [major] = packages['csv-parse'].version.split('.')
        major.should.be.above 3
