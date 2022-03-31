
mode = require '../../src/utils/mode'
{tags} = require '../test'

describe 'utils.mode', ->
  return unless tags.api

  describe 'stringify', ->
    
    it 'accept string', ->
      mode.stringify('544').should.eql '544'
    
    it 'accept number', ->
      mode.stringify(0o0744).should.eql '744'
      mode.stringify(0o1744).should.eql '1744'

  describe 'compare', ->

    it 'compare strings of same size', ->
      mode.compare('544', '544').should.be.true()
      mode.compare('544', '322').should.be.false()

    it 'compare strings of different sizes', ->
      mode.compare('544', '4544').should.be.true()
      mode.compare('544', '4543').should.be.false()
      mode.compare('0322', '322').should.be.true()
      mode.compare('0544', '322').should.be.false()
      mode.compare('100754', '744').should.be.false()

    it 'compare int with string', ->
      mode.compare(0o0744, '744').should.be.true()
      mode.compare(0o0744, '0744').should.be.true()

    it 'compare int with string', ->
      mode.compare('744', 0o0744).should.be.true()
      mode.compare('0744', 0o0744).should.be.true()

    it 'compare multiple arguments', ->
      mode.compare('744', 0o0744, '0744').should.be.true()

    it 'compare multiple arguments', ->
      mode.compare(['747', '744', '774'], 0o0744).should.be.true()
      mode.compare(['747', '774'], 0o0744).should.be.false()
