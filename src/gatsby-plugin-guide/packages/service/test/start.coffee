
nikita = require '@nikitajs/core/lib'
{tags, config, service} = require './test'
they = require('mocha-they')(config)

return unless tags.service_systemctl

describe 'service.start', ->
  
  @timeout 20000
  
  they 'should start', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service
        name: service.name
      @service.stop
        name: service.srv_name
      {$status} = await @service.start
        name: service.srv_name
      $status.should.be.true()
      {$status} = await @service.status
        name: service.srv_name
      $status.should.be.true()
      {$status} = await @service.start # Detect already started
        name: service.srv_name
      $status.should.be.false()
  
  they 'no error when invalid service name', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @service.start
        name: 'thisdoenstexit'
      $status.should.be.false()
