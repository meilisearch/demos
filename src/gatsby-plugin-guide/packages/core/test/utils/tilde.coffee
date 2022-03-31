
{tags} = require '../test'
tilde = require '../../src/utils/tilde'

describe 'utils.tilde', ->
  return unless tags.api

  describe 'normalize', ->

    it 'handle ~', ->
      tilde
      .normalize '~/.ssh'
      .should.finally.eql "#{process.env.HOME}/.ssh"

  describe 'resolve', ->

    it 'handle ~', ->
      tilde
      .resolve '/home/invalid/', '../overwritten', '~/.ssh', 'id_rsa'
      .should.finally.eql "#{process.env.HOME}/.ssh/id_rsa"
