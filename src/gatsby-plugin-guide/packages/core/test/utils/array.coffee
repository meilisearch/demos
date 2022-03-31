
{tags} = require '../test'
{intersect, flatten, merge, multiply, shuffle, unique} = require '../../src/utils/array'

describe 'utils.array', ->
  return unless tags.api

  # it 'compare', ->
  #   array.compare(['a'], ['a']).should.be.true()
  #   array.compare(['a', 'b'], ['a', 'b']).should.be.true()
  #   array.compare(['a', 'b'], ['a']).should.be.false()
  #   array.compare(['a'], ['a', 'b']).should.be.false()

  it 'flatten', ->
    flatten([['a'], ['b']]).should.eql ['a', 'b']
    flatten([['a',['b']], [['c', ['d']]]]).should.eql ['a', 'b', 'c', 'd']
    flatten([['a',['b']], [['c', ['d']]], ['e']], -1).should.eql ['a', 'b', 'c', 'd', 'e']
    flatten([['a',['b']], [['c', ['d']]], ['e']], 0).should.eql ['a', ['b'], ['c', ['d']], 'e']
    flatten([['a',['b']], [['c', ['d']]], ['e']], 1).should.eql ['a', 'b', 'c', ['d'], 'e']

  it 'intersect', ->
    intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
    intersect(['a', 'c', 'd'], []).should.eql []
    intersect([], ['e', 'd', 'c']).should.eql []

  it 'merge', ->
    merge(['a', 'b'], ['c', 'a']).should.eql ['a', 'b', 'c', 'a']

  it 'unique', ->
    unique(['a', 'b', 'c', 'a']).should.eql ['a', 'b', 'c']

  describe 'multiply', ->
  
    it 'object with object', ->
      multiply {a: ''}, {b: ''}
      .should.eql [
        [{a: ''}, {b: ''}]
      ]

    it 'object with [object]', ->
      multiply {a: 1}, [{b: 2}, {c: 3}]
      .should.eql [
        [ { a: 1 }, { b: 2 } ]
        [ { a: 1 }, { c: 3 } ]
      ]
        
    it 'string and [object]', ->
      multiply 'a', [{b: ''}, {c: ''}], 'd'
      .should.eql [
        ['a', {b: ''}, 'd'],
        ['a', {c: ''}, 'd']
      ]
        
    it '[object] with [object]', ->
      multiply [{a: ''}, {b: ''}], [{c: ''}, {d: ''}]
      .should.eql [
        [{a: ''}, {c: ''}],
        [{b: ''}, {c: ''}],
        [{a: ''}, {d: ''}],
        [{b: ''}, {d: ''}]
      ]

    it 'null with [object]', ->
      multiply null, [{b: 2}, {c: 3}]
      .should.eql [
        [ null, { b: 2 } ]
        [ null, { c: 3 } ]
      ]
        
  describe 'multiply', ->
    
    it 'empty array', ->
      shuffle([]).sort().should.eql []
        
    it 'one element array', ->
      shuffle([0]).sort().should.eql [0]
      
    it 'ensure all elements are still inside', ->
      shuffle([1,2,3]).sort().should.eql [1,2,3]
  
