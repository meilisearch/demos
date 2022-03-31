
utils = require '../../src/utils'
{tags} = require '../test'

describe 'utils.stats', ->
  return unless tags.api

  describe 'type', ->

    it 'directory is true', ->
      mode = parseInt '40755', 8
      utils.stats.isDirectory(mode).should.be.true()

    it 'directory is false', ->
      mode = parseInt '100644', 8
      utils.stats.isDirectory(mode).should.be.false()
      
  describe 'type', ->

    it 'file is true', ->
      mode = parseInt '100644', 8
      utils.stats.isFile(mode).should.be.true()

    it 'file is false', ->
      mode = parseInt '40755', 8
      utils.stats.isFile(mode).should.be.false()
      
  describe 'type', ->

    it 'file is false', ->
      utils.stats.type(parseInt('40755', 8)).should.eql 'Directory'
      utils.stats.type(parseInt('100644', 8)).should.eql 'File'
