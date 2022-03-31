
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.global', ->
  return unless tags.api
  
  it 'merge from root', ->
    nikita
      my_global:
        my_key: 'my value'
    , ->
      @call ->
        @call $global: 'my_global', ({config}) ->
          config.should.eql
            my_key: 'my value'
              
  it 'merge from parent', ->
    nikita ->
      @call
        my_global:
          my_key: 'my value'
      , ->
        @call $global: 'my_global', ({config}) ->
          config.should.eql
            my_key: 'my value'
              
  it 'merge from current', ->
    nikita ->
      @call
        $global: 'my_global'
        my_global:
          my_key: 'my value'
      , ({config}) ->
        config.should.eql
          my_key: 'my value'
            
  it 'declared at action registration', ->
    nikita ({registry})->
      registry.register ['my_action'],
        metadata:
          name: 'test'
          global: 'my_global'
        handler: ({config}) ->
          config: config
      {config} = await @my_action
        my_global:
          my_key: 'my value'
      config.should.eql
        my_key: 'my value'
        
