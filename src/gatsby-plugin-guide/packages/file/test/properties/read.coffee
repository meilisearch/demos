
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.properties.read', ->

  they 'read single key', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file.properties"
        content: "another_key=another value"
      {properties} = await @file.properties.read
        target: "#{tmpdir}/file.properties"
      properties.should.eql another_key: 'another value'

  they 'option separator', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file.properties"
        content: "another_key:another value"
      {properties} = await @file.properties.read
        target: "#{tmpdir}/file.properties"
        separator: ':'
      properties.should.eql another_key: 'another value'

  they 'option trim', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file.properties"
        content: "another_key : another value"
      {properties} = await @file.properties.read
        target: "#{tmpdir}/file.properties"
        separator: ':'
        trim: true
      properties.should.eql another_key: 'another value'
  
  they 'error if target does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties.read
        target: "#{tmpdir}/ohno"
      .should.be.rejectedWith code: 'NIKITA_FS_CRS_TARGET_ENOENT'
  
  they 'error missing target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties.read
        separator: ':'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `file.properties.read`:'
        '#/required config must have required property \'target\'.'
      ].join ' '
