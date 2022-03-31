
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'plugin.assertions assert_exists', ->
  return unless tags.posix

  they 'success if file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @fs.base.writeFile
        $assert_exists: "#{tmpdir}/a_file"
        content: ''
        target: "#{tmpdir}/a_file"
      .should.be.resolved()

  they 'success all files exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $assert_exists: [
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
      .should.be.resolved()

  they 'error if file missing', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $assert_exists: "#{tmpdir}/a_file"
        $handler: (->)
      .should.be.rejected()
