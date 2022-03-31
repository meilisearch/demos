
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.user.disable', ->
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.disable connection: ipa,
        username: 'test_user_disable'
      , ({config: {uid}}) ->
        uid.should.eql 'test_user_disable'
  
  describe 'action', ->
  
    they 'disable a missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.disable connection: ipa,
          uid: 'test_user_disable_missing'
        .should.be.rejectedWith
          code: 4001
          message: 'test_user_disable_missing: user not found'
  
    they 'disable an active user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del connection: ipa,
          $relax: true
          uid: 'test_user_disable_active'
        await @ipa.user connection: ipa,
          uid: 'test_user_disable_active'
          attributes:
            givenname: 'User'
            sn: 'Disable'
            mail: [
              'test_user_disable@nikita.js.org'
            ]
        {$status} = await @ipa.user.disable connection: ipa,
          uid: 'test_user_disable_active'
        $status.should.be.true()

  they 'disable an inactive user', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.user.del connection: ipa,
        $relax: true
        uid: 'test_user_disable_inactive'
      await @ipa.user connection: ipa,
        uid: 'test_user_disable_inactive'
        attributes:
          givenname: 'User'
          sn: 'Disable'
          mail: [
            'test_user_disable@nikita.js.org'
          ]
      await @ipa.user.disable connection: ipa,
        uid: 'test_user_disable_inactive'
      {$status} = await @ipa.user.disable connection: ipa,
        uid: 'test_user_disable_inactive'
      $status.should.be.false()
