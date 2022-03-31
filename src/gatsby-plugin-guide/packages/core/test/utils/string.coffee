
string = require '../../src/utils/string'
{tags} = require '../test'

describe 'utils.string', ->
  return unless tags.api

  it 'escapeshellarg', ->
    string.escapeshellarg("try to 'parse this").should.eql "'try to '\"'\"'parse this'"

  it 'hash', ->
    md5 = string.hash "hello"
    md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  it 'max', ->
    string.max('abcd', 10).should.eql('abcd')
    string.max('abcd', 2).should.eql('ab…')
    string.max('abcd', 3).should.eql('abc…')
    string.max('abcd', 4).should.eql('abcd')
