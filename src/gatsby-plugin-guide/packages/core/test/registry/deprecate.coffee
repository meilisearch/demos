
{tags} = require '../test'
nikita = require '../../src'

describe 'registry.deprecate', ->
  return unless tags.api

  it.skip 'function handler without new name', ->
    nikita
    .call ->
      nikita.registry.deprecate 'my_function', -> 'my_function'
    .call (_, next) ->
      nikita
      .my_function $relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated'
      .next next
    .call ->
      nikita.registry.unregister 'my_function'
    .promise()

  it.skip 'function handler with new name', ->
    nikita
    .call ->
      nikita.registry.deprecate 'my_function', 'my_new_function', -> 'my_function'
    .call (_, next) ->
      nikita
      .my_function $relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .next next
    .call ->
      nikita.registry.unregister 'my_function'
    .promise()

  it.skip 'string handler without new name', ->
    nikita
    .call ->
      nikita.registry.deprecate 'my_function', 'nikita/file/touch'
    .call (_, next) ->
      nikita
      .my_function $relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use nikita/file/touch'
      .next next
    .call ->
      nikita.registry.unregister 'my_function'
    .promise()

  it.skip 'string handler with new name', ->
    nikita
    .call ->
      nikita.registry.deprecate 'my_function', 'my_new_function', 'nikita/file/touch'
    .call (_, next) ->
      nikita
      .my_function $relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .next next
    .call ->
      nikita.registry.unregister 'my_function'
    .promise()
