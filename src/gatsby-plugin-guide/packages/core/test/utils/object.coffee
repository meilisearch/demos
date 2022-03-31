
{tags} = require '../test'
{copy, diff, equals, filter, match} = require '../../src/utils/object'

describe 'utils.object', ->
  return unless tags.api
  
  describe 'copy', ->
  
    it 'filter properties', ->
      copy {a: 'value 1', b: 'value 2', c: 1, d: 2}, ['a', 'c']
      .should.eql {a: 'value 1', c: 1}
        
    it 'is immutable', ->
      source = {a: 'value 1', b: 'value 2', c: 1, d: 2}
      copy source, ['a', 'c']
      source.should.eql {a: 'value 1', b: 'value 2', c: 1, d: 2}

  # describe 'equals', ->
  #   it 'two objects', ->
  #     equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true()
  #     equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false()
  #     equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true()
  #     equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true()
  #     equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false()

  describe 'diff', ->

    it 'two objects', ->
      diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.eql {}
      diff({a: '1', b: '21', c: '3'}, {a: '1', b: '22', c: '3'}, ['a', 'c']).should.eql {}
      diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}, ['a', 'c']).should.eql {'a': ['11', '12']}

    it 'two objects without keys', ->
      diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}).should.eql {}
      diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}).should.eql {'a': ['11', '12']}

  describe 'filter', ->
        
    it 'black list', ->
      filter a: 1, b: 2, c: 3, ['b']
      .should.eql a: 1, c: 3
    
    it 'white list', ->
      filter a: 1, b: 2, c: 3, null, ['b']
      .should.eql b: 2
        
    it 'black and white list', ->
      filter a: 1, b: 2, c: 3, ['b'], ['a', 'b']
      .should.eql a: 1
      
  describe 'match', ->
    
    describe 'scalar', ->
    
      it '0', ->
        match 0, 0
        .should.be.true()
        
      it 'null', ->
        match null, null
        .should.be.true()
        
      it 'null in object', ->
        match
          key: null
        ,
          key: null
        .should.be.true()
        
      it 'undefined', ->
        match undefined, undefined
        .should.be.true()
        
      it 'undefined in object', ->
        match
          key: undefined
        ,
          key: undefined
        .should.be.true()
      
    describe 'object', ->
    
      it 'object same', ->
        match
          a: '123'
          b: '456'
        ,
          a: '123'
          b: '456'
        .should.be.true()
          
      it 'object partial source', ->
        match
          a: '123'
        ,
          a: '123'
          b: '456'
        .should.be.false()
          
      it 'object partial target', ->
        match
          a: '123'
          b: '456'
        ,
          a: '123'
        .should.be.true()
        
      it 'deep object', ->
        match
          a: '123'
          c:
            c1: '456'
        ,
          c:
            c1: '456'
        .should.be.true()
          
    describe 'array', ->
    
      it 'same', ->
        match [
            '123', '456'
          ], [
            '123', '456'
          ]
        .should.be.true()
        
      it 'not same order', ->
        match [
            '123', '456'
          ], [
            '456', '123'
          ]
        .should.be.false()
        
      it 'deep', ->
        match [
            a:
              b: ['123', '456']
          ], [
            a:
              b: ['123', '456']
          ]
        .should.be.true()
        
    describe 'buffer', ->
          
      it 'true with source and target buffers', ->
        match
          a: '123'
          c:
            c1: Buffer.from '456'
        ,
          c:
            c1: Buffer.from '456'
        .should.be.true()
          
      it 'true if source string match target buffer', ->
        match
          a: '123'
          c:
            c1: '456'
        ,
          c:
            c1: Buffer.from '456'
        .should.be.true()
              
      it 'true if source buffer match target string', ->
        match
          a: '123'
          c:
            c1: Buffer.from '456'
        ,
          c:
            c1: '456'
        .should.be.true()
        
    describe 'regex', ->
          
      it 'true', ->
        match
          a: '123'
          c:
            c1: '456'
        ,
          c:
            c1: /^\d+$/
        .should.be.true()
          
      it 'false', ->
        match
          a: '123'
          c:
            c1: '456'
        ,
          c:
            c1: /^\d$/
        .should.be.false()
