
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_npm

describe 'tools.npm.uninstall', ->

  describe 'schema', ->

    it 'name is required', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @tools.npm.uninstall
          cwd: tmpdir
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'one error was found in the configuration of action `tools.npm.uninstall`:'
            '#/required config must have required property \'name\'.'
          ].join ' '

    it 'cwd or global is true are required', ->
      nikita.tools.npm.uninstall
        name: 'csv-parse'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `tools.npm.uninstall`:'
          '#/if config must match "then" schema, failingKeyword is "then";'
          '#/then/required config must have required property \'cwd\'.'
        ].join ' '

    it 'global is `true`', ->
      nikita.tools.npm.uninstall
        name: 'csv-parse'
        global: true
      , (->)

  describe 'action', ->

    they 'uninstall locally', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
        {$status} = await @tools.npm.uninstall
          cwd: tmpdir
          name: 'csv-parse'
        $status.should.be.true()
        {$status} = await @tools.npm.uninstall
          cwd: tmpdir
          name: 'csv-parse'
        $status.should.be.false()

    they 'uninstall locally in a current working directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir "#{tmpdir}/1_dir"
        @fs.mkdir "#{tmpdir}/2_dir"
        @tools.npm
          name: 'csv-parse'
          cwd: "#{tmpdir}/1_dir"
        @tools.npm
          name: 'csv-parse'
          cwd: "#{tmpdir}/2_dir"
        {$status} = await @tools.npm.uninstall
          cwd: "#{tmpdir}/1_dir"
          name: 'csv-parse'
        $status.should.be.true()
        {$status} = await @tools.npm.uninstall
          cwd: "#{tmpdir}/2_dir"
          name: 'csv-parse'
        $status.should.be.true()

    they 'uninstall globally', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @tools.npm
          name: 'csv-parse'
          global: true
        {$status} = await @tools.npm.uninstall
          name: 'csv-parse'
          global: true
        $status.should.be.true()
        {$status} = await @tools.npm.uninstall
          name: 'csv-parse'
          global: true
        $status.should.be.false()

    they 'uninstall multiple packages', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: ['csv-parse', 'csv']
        {$status} = await @tools.npm.uninstall
          cwd: tmpdir
          name: ['csv-parse', 'csv']
        $status.should.be.true()
    
    they 'name as argument', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
        {$status} = await @tools.npm.uninstall 'csv-parse',
          cwd: tmpdir
        $status.should.be.true()
