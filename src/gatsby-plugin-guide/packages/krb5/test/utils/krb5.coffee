
krb5 = require '../../src/utils/krb5'
tags = require '../test'

return unless tags.krb5

describe 'utils.krb5', ->

  describe 'kinit', ->

    it 'with password', ->
      krb5.kinit
        # username: 'myself'
        principal: 'myself@realm'
        password: 'myprecious'
      .should.eql 'echo myprecious | kinit myself@realm'

    it 'with keytab', ->
      krb5.kinit
        principal: 'myself@realm'
        keytab: '/tmp/keytab'
      .should.eql 'kinit -kt /tmp/keytab myself@realm'

    it 'with username', ->
      krb5.kinit
        principal: 'myself@realm'
        keytab: '/tmp/keytab'
        uid: 'me'
      .should.eql 'su - me -c \'kinit -kt /tmp/keytab myself@realm\''
