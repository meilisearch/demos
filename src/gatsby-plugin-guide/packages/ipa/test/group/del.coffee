
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.group.del', ->

  they 'delete a group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group connection: ipa,
        cn: 'group_del'
      {$status} = await @ipa.group.del connection: ipa,
        cn: 'group_del'
      $status.should.be.true()
      {$status} = await @ipa.group.del connection: ipa,
        cn: 'group_del'
      $status.should.be.false()
