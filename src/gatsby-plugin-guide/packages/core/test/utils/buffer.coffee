
{tags} = require '../test'
{trim} = require '../../src/utils/buffer'

describe 'utils.buffer', ->
  return unless tags.api
  
  describe 'trim', ->
  
    it 'remove whitespaces', ->
      buf = trim Buffer.from '\nok\n'
      buf.toString().should.eql 'ok'
