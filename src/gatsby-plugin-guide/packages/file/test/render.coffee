
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.render', ->

  describe 'error', ->

    they 'when option "source" doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          source: "#{tmpdir}/oups.hbs"
          target: "#{tmpdir}/output"
          context: {}
        .should.be.rejectedWith [
          'NIKITA_FS_CRS_TARGET_ENOENT:'
          'fail to read a file because it does not exist,'
          "location is \"#{tmpdir}/oups.hbs\"."
        ].join ' '

    they 'when option "context" is missing', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          content: 'Hello {{ who }}'
          target: "#{tmpdir}/output"
        .should.be.rejectedWith [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `file.render`:'
          '#/required config must have required property \'context\'.'
        ].join ' '

    they 'unsupported source extension', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          source: 'gohome.et'
          target: "#{tmpdir}/output"
          context: {}
        .should.be.rejectedWith
          message: "Invalid Option: extension '.et' is not supported"

    they 'disable templated', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.render
          content: 'Got {{ config.test }}'
          target: "#{tmpdir}/output"
          context: config: test: 'from context'
          test: 'from action'
        await @fs.assert
          target: "#{tmpdir}/output"
          content: 'Got from context'
  
  describe 'handlebars', ->

    they 'detect `source`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello {{ who }}'
        @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context: who: 'you'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello you'

    they 'check autoescaping (disabled)', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello "{{ who }}" \'{{ anInt }}\''
        @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context:
            who: 'you'
            anInt: 42
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello "you" \'42\''
