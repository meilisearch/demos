
{tags} = require '../test'
regexp = require '../../src/utils/regexp'

describe 'utils.regexp', ->
  return unless tags.api
  
  it 'is', ->
    regexp.is /.*/
    .should.be.true()
    regexp.is {}
    .should.be.false()

  it 'escape', ->
    regexp.escape '/.*/'
    .should.eql '/\\.\\*/'
