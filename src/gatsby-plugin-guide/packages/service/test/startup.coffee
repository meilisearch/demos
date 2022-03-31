
nikita = require '@nikitajs/core/lib'
{tags, config, service} = require './test'
they = require('mocha-they')(config)

return unless tags.service_startup

describe 'service.startup', ->
  
  @timeout 30000
  
  describe 'startup', ->

    they 'from service', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        {$status} = await @service
          name: service.name
          chk_name: service.chk_name
          startup: true
        $status.should.be.true()
        {$status} = await @service
          name: service.name
          chk_name: service.chk_name
          startup: true
        $status.should.be.false()
        {$status} = await @service
          name: service.name
          chk_name: service.chk_name
          startup: false
        $status.should.be.true()
        {$status} = await @service
          name: service.name
          chk_name: service.chk_name
          startup: false
        $status.should.be.false()

    they 'string argument', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service.install service.name
        @service.startup
          startup: false
          name: service.chk_name
        {$status} = await @service.startup service.chk_name
        $status.should.be.true()
