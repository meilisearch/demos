
memory = require '../../src/plugins/pubsub/engines/memory'
nikita = require '../../src'
{tags, config} = require '../test'
they = require('mocha-they')(config)


describe 'plugins.pubsub', ->
  return unless tags.api
  
  they 'set then get', ({ssh}) ->
    engine = memory()
    await nikita
      $ssh: ssh
      $pubsub: engine
    , ({tools: {pubsub}}) ->
      await pubsub.set 'a_key', 'a value'
    nikita
      $pubsub: engine
    , ({tools: {pubsub}}) ->
      value = await pubsub.get 'a_key'
      value.should.eql 'a value'
  
  they 'get then set', ({ssh}) ->
    engine = memory()
    new Promise (resolve, reject) ->
      nikita
        $ssh: ssh
        $pubsub: engine
      , ({tools: {pubsub}}) ->
        try
          value = await pubsub.get 'a_key'
          value.should.eql 'a value'
          resolve()
        catch err then reject err
      nikita
        $pubsub: engine
      , ({tools: {pubsub}}) ->
        await pubsub.set 'a_key', 'a value'
