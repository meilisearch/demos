
nikita = require '@nikitajs/core/lib'
{tags, config, krb5} = require './test'
they = require('mocha-they')(config)

return unless tags.krb5_delprinc

describe 'krb5.delprinc', ->

  they 'a principal which exists', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: krb5
    , ->
      await @krb5.addprinc
        principal: "nikita@#{krb5.realm}"
        randkey: true
      {$status} = await @krb5.delprinc
        principal: "nikita@#{krb5.realm}"
      $status.should.be.true()

  they 'a principal which does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: krb5
    , ->
      await @krb5.delprinc
        principal: "nikita@#{krb5.realm}"
      {$status} = await @krb5.delprinc
        principal: "nikita@#{krb5.realm}"
      $status.should.be.false()
