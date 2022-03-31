
nikita = require '@nikitajs/core/lib'
{tags, config, service} = require './test'
they = require('mocha-they')(config)

return unless tags.service_systemctl

describe 'service.stop', ->
  
  @timeout 20000

  they 'should stop', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service.install service.name
      @service.start service.srv_name
      {$status} = await @service.stop service.srv_name
      $status.should.be.true()
      {$status} = await @service.stop service.srv_name
      $status.should.be.false()

  they 'no error when invalid service name', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @service.stop
        name: 'thisdoenstexit'
      $status.should.be.false()
