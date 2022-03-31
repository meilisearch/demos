
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.user.status', ->
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
      .ipa.user.status connection: ipa,
        username: 'user_status'
      , ({config: {uid}}) ->
        uid.should.eql 'user_status'

  describe 'action', ->

    they 'get single user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {result} = await @ipa.user.status connection: ipa,
          uid: 'admin'
        result.dn.should.match /^uid=admin,cn=users,cn=accounts,/

    they 'get missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.status connection: ipa,
          uid: 'missing'
        .should.be.rejectedWith
          code: 4001
          message: 'missing: user not found'
