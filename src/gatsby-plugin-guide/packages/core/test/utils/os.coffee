
{tags} = require '../test'
{merge} = require 'mixme'
{whoami} = require '../../src/utils/os'
cleanup = (property, value) ->
  if value?
    process.env[property] = value
  else
    delete process.env[property]


describe 'utils.os', ->
  return unless tags.api

  describe 'whoami', ->
  
    it 'for ssh', ->
      ssh = {config: {username: 'ssh_username'}} # Fake SSH connection
      whoami(ssh: ssh, platform: 'linux').should.eql 'ssh_username'
      
    it 'for windows', ->
      {USERPROFILE} = process.env
      process.env['USERPROFILE'] = 'C:\\Users\\Zin_user'
      whoami(platform: 'win32').should.eql 'Zin_user'
      cleanup 'USERPROFILE', USERPROFILE
      
    it 'for linux root', ->
      {USER, HOME} = process.env
      delete process.env['USER'] # Found this on Docker environment
      process.env['HOME'] = '/root'
      whoami(platform: 'linux').should.eql 'root'
      cleanup 'USER', USER
      cleanup 'HOME', HOME
      
    it 'for linux user', ->
      {USER, HOME} = process.env
      delete process.env['USER'] # Found this on Docker environment
      process.env['HOME'] = '/home/linux_username'
      whoami(platform: 'linux').should.eql 'linux_username'
      cleanup 'USER', USER
      cleanup 'HOME', HOME
