
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.user.del', ->
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.del connection: ipa,
        username: 'test_user_del'

  describe 'action', ->
    
    they 'delete a missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.del connection: ipa,
          uid: 'test_user_del'
        {$status} = await @ipa.user.del connection: ipa,
          uid: 'test_user_del'
        $status.should.be.false()

    they 'delete a user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user connection: ipa,
          uid: 'test_user_del'
          attributes:
            givenname: 'User'
            sn: 'Delete'
            mail: [
              'test_user_del@nikita.js.org'
            ]
        {$status} = await @ipa.user.del connection: ipa,
          uid: 'test_user_del'
        $status.should.be.true()
