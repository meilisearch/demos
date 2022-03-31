
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.service.del', ->
  
  they 'delete a missing service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service.del connection: ipa,
        principal: 'test_service_del'
      {$status} = await @ipa.service.del connection: ipa,
        principal: 'test_service_del'
      $status.should.be.false()

  they 'delete a service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service connection: ipa,
        principal: 'test_service_del/ipa.nikita.local'
      {$status} = await @ipa.service.del connection: ipa,
        principal: 'test_service_del/ipa.nikita.local'
      $status.should.be.true()
