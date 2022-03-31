
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.dig', ->
  return unless tags.api

  it 'root action', ->
    nikita a_key: 'a value', ({tools: {dig}}) ->
      dig (action) ->
        action.config.a_key
      .should.be.resolvedWith ['a value']

  it 'traverse the parent hierarchy', ->
    nikita.call a_key: 1, ->
      @call a_key: 2, ->
        @call a_key: 3, ({tools: {dig}}) ->
          dig ({config}) ->
            config.a_key
          .should.be.resolvedWith [3, 2, 1]

  it 'traverse siblings', ->
    nikita.call a_key: 1, ->
      @call a_key: 2, (->)
      @call a_key: 3, ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith [3, 2, 1]

  it 'traverse siblings children', ->
    nikita.call a_key: '1', ->
      @call a_key: '2', ->
        @call a_key: '3', (->)
      @call a_key: '4', ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith ['4', '3', '2', '1']

  it 'traverse siblings children', ->
    nikita.call a_key: 1, ->
      @call a_key: 2, ->
      @call a_key: 3, ->
        @call (->)
        @call a_key: 4, ->
          @call a_key: 5, (->)
          @call a_key: 6, (->)
        @call (->)
        @call a_key: 7, (->)
      @call a_key: 8, ->
      @call a_key: 9, ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith [9, 8, 7, 6, 5, 4, 3, 2, 1]
