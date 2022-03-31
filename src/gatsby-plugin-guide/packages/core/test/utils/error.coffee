
{tags} = require '../test'
error = require '../../src/utils/error'

describe 'utils.error', ->
  return unless tags.api
  
  describe 'function', ->
  
    it 'accept a code and an array message', ->
      (->
        throw error 'AN_ERROR', ['this is', 'an error']
      ).should.throw
        message: 'AN_ERROR: this is an error'
        code: 'AN_ERROR'
          
    it 'skip undefined lines in message', ->
      (->
        throw error 'AN_ERROR', ['this is', undefined, 'an error']
      ).should.throw 'AN_ERROR: this is an error'
  
  describe 'got', ->
    
    it 'print a string', ->
      error.got('hello').should.eql '"hello"'
    
    it 'print a function', ->
      error.got(->).should.eql 'function'
    
    it 'print an array with functions', ->
      error.got([->, [->]]).should.eql '[function,[function]]'
    
    it 'array reaches depth max_depth 3', ->
      error.got(
        [1, [2], [[3]], [[[4]]]]
      ).should.eql '[1,[2],[[3]],[[[…]]]]'
    
    it 'with max_depth 1', ->
      error.got([1], max_depth: 1).should.eql '[1]'
      error.got([[2]], max_depth: 1).should.eql '[[…]]'
