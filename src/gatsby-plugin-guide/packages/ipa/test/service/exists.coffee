
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.service.exists', ->

  they 'service doesnt exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service.del connection: ipa,
        principal: 'service_exists/ipa.nikita.local'
      {$status, exists} = await @ipa.service.exists connection: ipa,
        principal: 'service_exists/ipa.nikita.local'
      $status.should.be.false()
      exists.should.be.false()

  they 'service exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service connection: ipa,
        principal: 'service_exists/ipa.nikita.local'
      {$status, exists} = await @ipa.service.exists connection: ipa,
        principal: 'service_exists/ipa.nikita.local'
      $status.should.be.true()
      exists.should.be.true()
      @ipa.service.del connection: ipa,
        principal: 'service_exists/ipa.nikita.local'
