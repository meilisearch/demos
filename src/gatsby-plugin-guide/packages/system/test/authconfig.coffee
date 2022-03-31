
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.system_authconfig

describe 'system.authconfig', ->
    
  they 'edit empty sysconfig file', ({sudo ,ssh}) ->
    # Note, after authconfig package installation,
    # the configuration file exists and is empty
    nikita
      $ssh: ssh
    , ->
      # Init
      @system.authconfig
        target: '/etc/sysconfig/authconfig'
        properties:
          mkhomedir: true
      # Change to negative
      {$status} = await @system.authconfig
        target: '/etc/sysconfig/authconfig'
        properties: {
          mkhomedir: false
        }
      $status.should.be.true()
      # Preserve negative
      {$status} = await @system.authconfig
        target: '/etc/sysconfig/authconfig'
        properties:
          mkhomedir: false
      $status.should.be.false()
      # Change to positive
      {$status} = await @system.authconfig
        target: '/etc/sysconfig/authconfig'
        properties:
          mkhomedir: true
      $status.should.be.true()
      {$status} = await @system.authconfig
        target: '/etc/sysconfig/authconfig'
        properties:
          mkhomedir: true
      $status.should.be.false()
    
