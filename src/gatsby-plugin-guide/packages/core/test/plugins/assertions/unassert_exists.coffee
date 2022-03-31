
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'plugin.assertions unassert_exists', ->
  return unless tags.posix

  they 'success if no file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $unassert_exists: "#{tmpdir}/a_file"
      , (->)
      .should.be.resolved()

  they 'error if file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @fs.base.writeFile
        $unassert_exists: "#{tmpdir}/a_file"
        content: ''
        target: "#{tmpdir}/a_file"
      .should.be.rejected()

  they 'error if all file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $unassert_exists: [
          "#{tmpdir}/file_1"
          "#{tmpdir}/file_2"
        ]
      , ->
        @fs.base.writeFile
          content: ''
          target: "#{tmpdir}/file_1"
        @fs.base.writeFile
          content: ''
          target: "#{tmpdir}/file_2"
      .should.be.rejected()

  they 'error if one file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $unassert_exists: [
          "#{tmpdir}/file_1"
          "#{tmpdir}/file_2"
          "#{tmpdir}/file_3"
        ]
      , ->
        @fs.base.writeFile
          content: ''
          target: "#{tmpdir}/file_2"
      .should.be.rejected()

  they 'success if no file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $unassert_exists: [
          "#{tmpdir}/file_1"
          "#{tmpdir}/file_2"
        ]
      , (->)
      .should.be.resolved()

  they 'success if file missing', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $unassert_exists: "#{tmpdir}/a_file"
        $handler: (->)
      .should.be.resolved()
