
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa
describe 'ipa.group.add_member', ->

  they 'add_member to a group', ({ssh}) ->
    gidnumber = null
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: ipa, [
        cn: 'group_add_member'
      ,
        cn: 'group_add_member_user'
      ]
      await @ipa.user.del connection: ipa,
        uid: 'group_add_member_user'
      {result} = await @ipa.group connection: ipa,
        cn: 'group_add_member'
      gidnumber = result.gidnumber
      await @ipa.user connection: ipa,
        uid: 'group_add_member_user'
        attributes:
          givenname: 'Firstname'
          sn: 'Lastname'
          mail: [ 'user@nikita.js.org' ]
      {$status} = await @ipa.group.add_member connection: ipa,
        cn: 'group_add_member'
        attributes:
          user: ['group_add_member_user']
      $status.should.be.true()
      {result} = await @ipa.group.show connection: ipa,
        cn: 'group_add_member'
      result.gidnumber.should.eql gidnumber
