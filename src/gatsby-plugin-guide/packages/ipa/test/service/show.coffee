
nikita = require '@nikitajs/core/lib'
{tags, config, ipa} = require '../test'
they = require('mocha-they')(config)

return unless tags.ipa

describe 'ipa.service.show', ->

  they 'get single service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {result} = await @ipa.service.show connection: ipa,
        principal: 'HTTP/ipa.nikita.local'
      result.dn.should.eql 'krbprincipalname=HTTP/ipa.nikita.local@NIKITA.LOCAL,cn=services,cn=accounts,dc=nikita,dc=local'

  they 'get missing service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service.show connection: ipa,
        principal: 'missing/ipa.nikita.local'
      .should.be.rejectedWith
        code: 4001
        message: 'missing/ipa.nikita.local@NIKITA.LOCAL: service not found'
