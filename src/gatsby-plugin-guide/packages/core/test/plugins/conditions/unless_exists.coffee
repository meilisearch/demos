
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'plugin.conditions unless_exists', ->
  return unless tags.posix
  
  describe 'array', ->

    they 'skip if all conditions are `true`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $unless_exists: [
            "#{tmpdir}"
            "#{tmpdir}"
          ]
        , -> throw Error 'forbidden'

    they 'skip if one conditions are `true`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $unless_exists: [
            "#{tmpdir}"
            "#{tmpdir}/ohno"
            "#{tmpdir}"
          ]
        , -> throw Error 'forbidden'

    they 'called if all conditions are `false`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $unless_exists: [
            "#{tmpdir}/ohno"
            "#{tmpdir}/ohno"
            "#{tmpdir}/ohno"
          ]
          $handler: -> 'called'
        .should.be.finally.eql 'called'
  
  describe 'string', ->

    they 'skip if file exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {called} = await @call
          $unless_exists: "#{tmpdir}"
          $handler: -> called: true
        (called is undefined).should.be.true()

    they 'run if file doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $unless_exists: "#{tmpdir}/ohno"
          $handler: -> 'called'
        .should.be.finally.eql 'called'
