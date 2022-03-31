
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.properties', ->

  they 'overwrite by default', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
      .should.be.finally.containEql $status: true
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
      .should.be.finally.containEql $status: true
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
      .should.be.finally.containEql $status: false
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "another_key=another value\n"

  they 'option merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
      .should.be.finally.containEql $status: true
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        merge: true
      .should.be.finally.containEql $status: true
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        merge: true
      .should.be.finally.containEql $status: false
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=a value\nanother_key=another value\n"

  they 'honor separator', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: a_key: 'a value'
        separator: ' '
      @file.properties
        target: "#{tmpdir}/file.properties"
        content: another_key: 'another value'
        separator: ' '
        merge: true
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key a value\nanother_key another value\n"

  they 'honor sort', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'value'
          a_key: 'value'
        sort: false
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "b_key=value\na_key=value\n"
      @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'value'
          a_key: 'value'
        sort: true
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=value\nb_key=value\n"

  they 'option comments', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file.properties"
        content: """
        a_key=value
        # comment
        b_key=value
        """
      @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          b_key: 'new value'
          a_key: 'new value'
        merge: true
        comment: true
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=new value\n# comment\nb_key=new value\n"

  they 'option trim + merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file.properties"
        content: """
        a_key = a value
        """
      @file.properties
        target: "#{tmpdir}/file.properties"
        content:
          'b_key ': ' b value'
        merge: true
        trim: true
      @fs.assert
        target: "#{tmpdir}/file.properties"
        content: "a_key=a value\nb_key=b value\n"
