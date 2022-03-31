
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugin.conditions unless', ->
  return unless tags.api
  
  describe 'array', ->

    it 'skip if all true', ->
      nikita .call
        $unless: [true, true, true]
        $handler: -> throw Error 'You are not welcome here'

    it 'skip if at least one is true', ->
      nikita.call
        $unless: [false, true, false]
        $handler: -> throw Error 'You are not welcome here'

    it 'run if all false', ->
      nikita.call
        $unless: [false, false, false]
        $handler: -> 'called'
      .should.be.finally.eql 'called'
  
  describe 'boolean, integer', ->

    it 'skip if `true`', ->
      nikita.call
        $unless: true
        $handler: -> throw Error 'You are not welcome here'

    it 'skip if `1`', ->
      nikita.call
        $unless: 1
        $handler: -> throw Error 'You are not welcome here'

    it 'run if `0`', ->
      nikita.call
        $unless: 0
        $handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'run if `false`', ->
      nikita.call
        $unless: false
        $handler: -> 'called'
      .should.be.finally.eql 'called'
          
  describe 'null, undefined', ->

    it 'run if `null`', ->
      nikita.call
        $unless: null
        $handler: -> 'called'
      .should.be.finally.eql 'called'
    
  describe 'string + buffer', ->

    it 'skip if string not empty', ->
      nikita.call
        $unless: 'abc'
      , -> throw Error 'You are not welcome here'

    it 'run if string empty', ->
      {$status, value} = await nikita.call
        $unless: ''
        $handler: -> $status: true, value: 'called'
      $status.should.be.true()
      value.should.eql 'called'

    it 'skip if buffer length > 1', ->
      nikita.call
        $unless: Buffer.from 'abc'
        $handler: -> throw Error 'You are not welcome here'

    it 'run if buffer length is 0', ->
      nikita.call
        $unless: Buffer.from ''
        $handler: -> 'called'
      .should.be.finally.eql 'called'
  
  describe 'object', ->

    it 'skip if `{k:v}`', ->
      nikita.call
        $unless: {k:"v"}
        $handler: -> throw Error 'You are not welcome here'

    it 'run if `{}`', ->
      nikita.call
        $unless: {}
        $handler: -> 'called'
      .should.be.finally.eql 'called'
  
  describe 'function', ->

    it 'skip if function casts to true', ->
      {$status} = await nikita.call
        $unless: -> true
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()
      {$status} = await nikita.call
        $unless: -> 'abc'
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()

    it 'skip if promise resolves with true', ->
      {$status} = await nikita.call
        $unless: ->
          new Promise (accept, reject) -> accept true
        $handler: -> throw Error 'You are not welcome here'
      $status.should.be.false()

    it 'run if function casts to false', ->
      {$status, value} = await nikita.call
        $unless: -> false
        $handler: -> true
      $status.should.be.true()
      {$status, value} = await nikita.call
        $unless: -> ''
        $handler: -> true
      $status.should.be.true()

    it 'run if promise resolves with false', ->
      {$status, value} = await nikita.call
        $unless: -> false
        $handler: -> true
      $status.should.be.true()

    it 'pass error on rejected promise', ->
      nikita.call
        $unless: ->
          new Promise (accept, reject) ->
            reject Error 'Cool'
        $handler: -> throw Error 'You are not welcome here'
      .should.rejectedWith 'Cool'
