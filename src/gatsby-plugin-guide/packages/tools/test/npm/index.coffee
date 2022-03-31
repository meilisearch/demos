
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_npm

describe 'tools.npm', ->

  describe 'schema', ->

    it 'name is required', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @tools.npm
          cwd: tmpdir
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'one error was found in the configuration of action `tools.npm`:'
            '#/required config must have required property \'name\'.'
          ].join ' '

    it 'cwd or global is true are required', ->
      nikita.tools.npm
        name: 'csv-parse'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `tools.npm`:'
          '#/if config must match "then" schema, failingKeyword is "then";'
          '#/then/required config must have required property \'cwd\'.'
        ].join ' '

    it 'global is `true`', ->
      nikita.tools.npm
        name: 'csv-parse'
        global: true
      , (->)

    it 'global is `false` without `cwd`', ->
      nikita.tools.npm
        name: 'csv-parse'
        global: false
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /#\/then\/required config must have required property 'cwd'/

  describe 'action', ->

    they 'option `cwd`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
        $status.should.be.true()
        {$status} = await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
        $status.should.be.false()

    they 'option `cwd` with 2 separate directories', ({ssh}) ->
      # not sure this is really relevant
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir "#{tmpdir}/1_dir"
        @fs.mkdir "#{tmpdir}/2_dir"
        {$status} = await @tools.npm
          cwd: "#{tmpdir}/1_dir"
          name: 'csv-parse'
        $status.should.be.true()
        {$status} = await @tools.npm
          cwd: "#{tmpdir}/2_dir"
          name: 'csv-parse'
        $status.should.be.true()

    they 'option `global`', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @tools.npm.uninstall
          name: 'csv-parse'
          global: true
          # sudo: true
        {$status} = await @tools.npm
          name: 'csv-parse'
          global: true
          # sudo: true
        $status.should.be.true()
        {$status} = await @tools.npm
          name: 'csv-parse'
          global: true
          # sudo: true
        $status.should.be.false()

    they 'option `name` as an array', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @tools.npm
          cwd: tmpdir
          name: ['csv-parse', 'csv']
        $status.should.be.true()
        {$status} = await @tools.npm
          cwd: tmpdir
          name: ['csv-parse', 'csv']
        $status.should.be.false()

    they 'option `upgrade`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @tools.npm
          cwd: tmpdir
          name: 'csv-parse@3.0.0'
        {$status} = await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
          upgrade: true
        $status.should.be.true()
        {$status} = await @tools.npm
          cwd: tmpdir
          name: 'csv-parse'
          upgrade: true
        $status.should.be.false()

    they 'metadata `argument_to_config`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @tools.npm 'csv-parse',
          cwd: tmpdir
        $status.should.be.true()
