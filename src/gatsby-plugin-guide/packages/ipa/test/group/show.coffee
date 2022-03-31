
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.group.show', ->

  they 'get single group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {result} = await @ipa.group.show connection: ipa,
        cn: 'admins'
      result.gidnumber[0].should.match /\d+/
      result.gidnumber[0] = '0000000000'
      result.should.eql
        dn: 'cn=admins,cn=groups,cn=accounts,dc=nikita,dc=local',
        gidnumber: [ '0000000000' ],
        member_user: [ 'admin' ],
        description: [ 'Account administrators group' ],
        cn: [ 'admins' ]

  they 'get missing group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group.show connection: ipa,
        cn: 'missing'
      .should.be.rejectedWith
        code: 4001
        message: 'missing: group not found'
