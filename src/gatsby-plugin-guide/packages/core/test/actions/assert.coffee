
{tags} = require '../test'
nikita = require '../../src'
registry = require '../../src/registry'

describe 'actions.assert', ->
  return unless tags.api
  
  describe 'returned value', ->

    it 'fulfilled with `true`', ->
      nikita.assert ->
        true
      .should.be.fulfilled()

    it 'rejected with `false`', ->
      nikita.assert ->
        false
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'cast', ->
      # String
      await nikita.assert ->
        'valid'
      .should.be.fulfilled()
      await nikita.assert ->
        ''
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Buffer
      await nikita.assert ->
        Buffer.from 'valid'
      .should.be.fulfilled()
      await nikita.assert ->
        Buffer.from ''
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Integer
      await nikita.assert ->
        1
      .should.be.fulfilled()
      await nikita.assert ->
        0
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Object literal
      await nikita.assert ->
        key: 'value'
      .should.be.fulfilled()
      await nikita.assert ->
        {}
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      # Null and undefined
      await nikita.assert ->
        null
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      await nikita.assert ->
        undefined
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'handle array', ->
      await nikita.assert ->
        [true, true]
      .should.be.fulfilled()
      await nikita.assert ->
        [false, true]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'succeed when promise true is returned', ->
      nikita.assert ->
        new Promise (resolve) ->
          resolve true

    it 'fail when promise false is returned', ->
      nikita.assert ->
        new Promise (resolve) ->
          resolve false
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'multiple actions, all resolve true', ->
      nikita.assert [
          -> true
        ,
          -> new Promise (resolve) -> resolve true
        ]
      .should.be.fulfilled()

    it 'multiple actions, one resolve false', ->
      nikita.assert [
          -> true
        ,
          -> new Promise (resolve) -> resolve false
        ,
          -> true
        ]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'

    it 'children must return true', ->
      await nikita.assert ->
        @call [
          $raw_output: true
          $handler: -> true
        ,
          $raw_output: true
          $handler: -> new Promise (resolve) -> resolve true
        ]
      .should.be.fulfilled()
      await nikita.assert ->
        @call [
          $raw_output: true
          $handler: -> true
        ,
          $raw_output: true
          $handler: -> new Promise (resolve) -> resolve false
        ]
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
    
    describe 'option `not`', ->

      it 'succeed only with false', ->
        await nikita.assert not: true, ->
          false
        .should.be.fulfilled()
        await nikita.assert not: true, ->
          true
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'

      it 'cast', ->
        # String
        await nikita.assert not: true, ->
          'false'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        await nikita.assert not: true, ->
          ''
        .should.be.fulfilled()
        # Buffer
        await nikita.assert not: true, ->
          Buffer.from 'valid'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        await nikita.assert not: true, ->
          Buffer.from ''
        .should.be.fulfilled()
        # Integer
        await nikita.assert not: true, ->
          1
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        await nikita.assert not: true, ->
          0
        .should.be.fulfilled()
        # Object literal
        await nikita.assert not: true, ->
          key: 'value'
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        await nikita.assert not: true, ->
          {}
        .should.be.fulfilled()
        # Null and undefined
        await nikita.assert not: true, ->
          null
        .should.be.fulfilled()
        await nikita.assert not: true, ->
          undefined
        .should.be.fulfilled()

      it 'handle array', ->
        await nikita.assert not: true, ->
          [false, false]
        .should.be.fulfilled()
        await nikita.assert not: true, ->
          [false, true]
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
        await nikita.assert not: true, ->
          [true, true]
        .should.be.rejectedWith
          code: 'NIKITA_ASSERT_UNTRUE'
    
  describe 'option `strict`', ->

    it 'succeed only with false', ->
      await nikita.assert strict: true, ->
        'very strict'
      .should.be.rejectedWith
        code: 'NIKITA_ASSERT_UNTRUE'
      await nikita.assert strict: true, not: true, ->
        'very strict'
      .should.be.fulfilled()
      
