
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.user.exists', ->

  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.exists connection: ipa,
        username: 'user_exists'

  describe 'action', ->

    they 'user doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.del connection: ipa,
          uid: 'user_exists'
        {$status, exists} = await @ipa.user.exists connection: ipa,
          uid: 'user_exists'
        $status.should.be.false()
        exists.should.be.false()

    they 'user exists', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user connection: ipa,
          uid: 'user_exists'
          attributes:
            givenname: 'Firstname'
            sn: 'Lastname'
            mail: [
              'user@nikita.js.org'
            ]
        {$status, exists} = await @ipa.user.exists connection: ipa,
          uid: 'user_exists'
        $status.should.be.true()
        exists.should.be.true()
