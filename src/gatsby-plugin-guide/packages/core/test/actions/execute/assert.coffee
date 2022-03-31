
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.assert', ->
  return unless tags.posix
  
  describe 'schema', ->
    
    it 'coercion', ->
      nikita.execute.assert
        command: 'exit 1'
        code: 1
        ({config}) ->
          config.code.should.eql [1]
  
  describe 'exit code', ->

    they 'assert command succeed', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute.assert
          command: 'exit 0'

    they 'assert command fail', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute.assert
          command: 'exit 1'
        .should.be.rejectedWith [
          'NIKITA_EXECUTE_ASSERT_EXIT_CODE:'
          'an unexpected exit code was encountered,'
          'got undefined while expecting 0.'
        ].join ' '

    they 'assert custom code', ({ssh}) ->
      nikita $ssh: ssh, ->
        await @execute.assert
          command: 'exit 1'
          code: 1
        @execute.assert
          command: 'exit 0'
          code: 1
        .should.be.rejectedWith [
          'NIKITA_EXECUTE_ASSERT_EXIT_CODE:'
          'an unexpected exit code was encountered,'
          'got undefined while expecting 1.'
        ].join ' '

    they 'assert custom code with negation', ({ssh}) ->
      nikita $ssh: ssh, ->
        await @execute.assert
          command: 'exit 1'
          not: true
          code: 0
        @execute.assert
          command: 'exit 0'
          not: true
          code: 0
        .should.be.rejectedWith [
          'NIKITA_EXECUTE_ASSERT_NOT_EXIT_CODE:'
          'an unexpected exit code was encountered,'
          'got 0 while expecting anything but 0.'
        ].join ' '
          
  describe 'content', ->

    they 'assert stdout match content', ({ssh}) ->
      nikita $ssh: ssh, ->
        await @execute.assert
          command: 'text=hello; echo $text'
          content: 'hello\n'
        @execute.assert
          command: 'text=hello; echo $text'
          content: 'hello'
        .should.be.rejectedWith [
          'NIKITA_EXECUTE_ASSERT_CONTENT:'
          'the command output is not matching the content,'
          'got "hello\\n" while expecting to match "hello".'
        ].join ' '

    they 'assert stdout match regexp', ({ssh}) ->
      nikita $ssh: ssh, ->
        await @execute.assert
          command: "echo \"toto\nest\r\nau\rbistrot\""
          content: /^bistrot$/m
        @execute.assert
          command: "echo \"toto\nest\r\nau\rbistrot\""
          content: /^ohno$/m
        .should.be.rejectedWith [
          'NIKITA_EXECUTE_ASSERT_CONTENT_REGEX:'
          'the command output is not matching the content regexp,'
          'got "toto\\nest\\r\\nau\\rbistrot\\n" while expecting to match {}.'
        ].join ' '

    they 'option trim on command', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute.assert
          command: "echo '' && echo 'yo'"
          content: 'yo'
          trim: true

    they 'option trim on content', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute.assert
          bash: true
          command: "echo -n 'yo'"
          content: '\nyo\n'
          trim: true
