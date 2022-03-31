
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.templated', ->
  return unless tags.api

  it 'access config', ->
    nikita
      $templated: true
      key_1: 'value 1'
      key_2: 'value 2 and {{config.key_1}}'
      $handler: ({config}) -> config
    .should.be.finally.containEql
      key_1: 'value 1'
      key_2: 'value 2 and value 1'
  
  it 'access parent', ->
    nikita
      $templated: true
      key: 'value'
    , ->
      @call
        key: "get {{parent.config.key}} from parent"
      , ({config}) -> config
      .should.be.finally.containEql
        key: 'get value from parent'
  
  describe 'disabled with value `false`', ->

    it 'access value in metadata', ->
      nikita.call
        $templated: false
      , ({metadata: {templated}}) ->
        templated.should.be.false()

    it 'disabled in current', ->
      nikita
        $templated: false
        key_1: 'value 1'
        key_2: 'value 2 and {{config.key_1}}'
      , ({config}) -> config
      .should.be.finally.containEql
        key_1: 'value 1'
        key_2: 'value 2 and {{config.key_1}}'

    it 'disabled from parent', ->
      nikita
        $templated: true
      , ->
        @call
          $templated: false
        , ->
          @call ->
            @call ->
              key_1: 'value 1'
              key_2: 'value 2 and {{config.key_1}}'
              handler: ({config}) -> config
            .should.be.finally.containEql
              key_1: 'value 1'
              key_2: 'value 2 and {{config.key_1}}'
          
