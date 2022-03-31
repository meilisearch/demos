
nikita = require '@nikitajs/core/lib'
{tags, config, service} = require './test'
they = require('mocha-they')(config)

return unless tags.service_systemctl

describe 'service.status', ->
  
  @timeout 20000
  
  they 'store status', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service
        name: service.name
      @service.stop
        name: service.srv_name
      {$status} = await @service.status
        name: service.srv_name
      $status.should.be.false()
      @service.start
        name: service.srv_name
      {$status} = await @service.status
        name: service.srv_name
      $status.should.be.true()
      @service.stop
        name: service.srv_name
      {$status} = await @service.status
        name: service.name
        srv_name: service.srv_name
      $status.should.be.false()
