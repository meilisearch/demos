
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.group.exists', ->

  they 'group doesnt exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group.del connection: ipa,
        cn: 'group_exists'
      {$status, exists} = await @ipa.group.exists connection: ipa,
        cn: 'group_exists'
      $status.should.be.false()
      exists.should.be.false()

  they 'group exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group connection: ipa,
        cn: 'group_exists'
      {$status, exists} = await @ipa.group.exists connection: ipa,
        cn: 'admins'
      $status.should.be.true()
      exists.should.be.true()
