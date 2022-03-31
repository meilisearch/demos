
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.raw_input', ->
  return unless tags.api
  
  it 'validate schema', ->
    nikita
      $raw_input: [false, false]
      $handler: (->)
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      message: [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/raw_input/type'
        'metadata/raw_input must be boolean,'
        'type is "boolean".'
      ].join ' '
    
  it 'get default from `raw`', ->
    await nikita
      $raw: true
    , ({metadata}) ->
      metadata.raw_input.should.be.true()
    await nikita
      $raw: false
    , ({metadata}) ->
      metadata.raw_input.should.be.false()
    await nikita
      $raw: undefined
    , ({metadata}) ->
      metadata.raw_input.should.be.false()

  it 'argument is `true`', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'],
        metadata: raw_input: true
        handler: ({config, args}) ->
          config: config
          args: args
    .an.action true
    .should.be.finally.match
      args: [true]
      config: {}
      
  it 'argument is `false`', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'],
        metadata: raw_input: true
        handler: ({config, args}) ->
          config: config
          args: args
    .an.action false
    .should.be.finally.match
      args: [false]
      config: {}

  it 'no argument', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'],
        metadata: raw_input: true
        handler: ({config, args}) ->
          config: config
          args: args
    .an.action()
    .should.be.finally.match
      args: []
      config: {}

  it 'argument is `{}`', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'],
        metadata: raw_input: true
        handler: ({config, args}) ->
          config: config
          args: args
    .an.action {}
    .should.be.finally.match
      args: [{}]
      config: {}

  it 'multiple arguments', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'],
        metadata: raw_input: true
        handler: ({args, config}) ->
          args: args
          config: config
    .an.action 'an argument', a_key: 'a value'
    .should.be.finally.match
      args: ['an argument', a_key: 'a value']
      config: {}

  it 'with metadata `argument`', ->
    nikita true, $raw_input: true, (action) ->
      config: action.config
      argument: action.metadata.argument
    .should.be.finally.containEql
      config: {}
      argument: true
      $status: false
