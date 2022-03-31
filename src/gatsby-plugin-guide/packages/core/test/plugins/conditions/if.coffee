
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugin.conditions if', ->
  return unless tags.api
  
  describe 'array', ->

    it 'run if all conditions are `true`', ->
      nikita.call
        $if: [true, true]
        $handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if one conditions is `false`', ->
      nikita.call
        $if: [true, false, true]
        $handler: -> throw Error 'forbidden'
  
  describe 'boolean, integer', ->

    it 'run if `true`', ->
      nikita.call
        $if: true
        $handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if `false`', ->
      nikita.call
        $if: false
        $handler: -> throw Error 'forbidden'

    it 'run if `1`', ->
      nikita.call
        $if: 1
        $handler: -> 'called'
      .should.finally.eql 'called'

    it 'skip if `0`', ->
      nikita.call
        $if: 0
        $handler: -> throw Error 'forbidden'
          
  describe 'null, undefined', ->

    it 'skip if `null`', ->
      nikita.call
        $if: null
        $handler: -> throw Error 'forbidden'

    it 'skip if `undefined`', ->
      nikita.call
        $if: undefined
        $handler: -> throw Error 'forbidden'
  
  describe 'string + buffer', ->
  
    it 'run if `"string"`', ->
      nikita.call
        $if: 'abc'
        $handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'run if `{{"string"}}`', ->
      count = 0
      nikita
      .call
        $if: '{{config.db.test}}'
        $templated: true
        db: test: 'abc'
      , ->
        count++
      .call ->
        count.should.equal 1

    it 'skip if `""`', ->
      nikita.call
        $if: ''
        $handler: -> throw Error 'forbidden'

    it 'skip if `{{""}}`',->
      nikita.call
        $if: '{{config.db.test}}'
        $templated: true
        $handler: -> throw Error 'forbidden'
        db: test: ''

    it 'run if buffer length > 1', ->
      nikita.call
        $if: Buffer.from 'abc'
        $handler: -> 'called'
      .should.finally.eql 'called'

    it 'skip if buffer length is empty', ->
      nikita.call
        $if: Buffer.from ''
        $handler: -> throw Error 'forbidden'
    
  describe 'object', ->

    it 'run if `{k:v}`', ->
      nikita.call
        $if: {k:"v"}
        $handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if `{}`', ->
      nikita.call
        $if: {}
        $handler: -> throw Error 'forbidden'
  
  describe 'function', ->
    
    it 'contains metadata depth', ->
      nikita.call
        $if: ({metadata}) ->
          metadata.depth.should.eql 2
        $handler: -> 'ok'
      .should.be.finally.eql 'ok'

    it 'contains config', ->
      nikita.call
        $if: ({config}) ->
          config.a_key.should.eql 'a value'
        $handler: -> 'ok'
        a_key: 'a value'
      .should.be.finally.eql 'ok'

    it 'run if function casts to true', ->
      {$status, value} = await nikita.call
        $if: -> true
        $handler: -> $status: true, value: 'called'
      $status.should.be.true()
      value.should.eql 'called'
      {$status, value} = await nikita.call
        $if: -> 'abc'
        $handler: -> $status: true, value: 'called'
      $status.should.be.true()
      value.should.eql 'called'

    it 'run if promise resolves with true', ->
      {$status, value} = await nikita.call
        $if: ->
          new Promise (accept, reject) -> accept true
        $handler: -> $status: true, value: 'called'
      $status.should.be.true()
      value.should.eql 'called'

    it 'skip if function casts to false', ->
      {$status} = await nikita.call
        $if: -> false
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()
      {$status} = await nikita.call
        $if: -> ''
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()

    it 'skip if promise resolves with false', ->
      {$status, value} = await nikita.call
        $if: ->
          new Promise (accept, reject) -> accept false
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()
    
