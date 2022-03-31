
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.json', ->

  they 'stringify content to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/target.json"
        content: 'doesnt have to be valid json'
      @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"user":"usrval"}'

  they 'merge target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"overwrite"}'
      @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"usrval"}'

  they 'merge source', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/source.json"
        content: '{"source":"srcval","user":"overwrite"}'
      @file.json
        source: "#{tmpdir}/source.json"
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"source":"srcval","user":"usrval"}'

  they 'merge source and traget', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/source.json"
        content: '{"source":"srcval","target":"overwrite","user":"overwrite"}'
      @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"tarval","user":"overwrite"}'
      @file.json
        source: "#{tmpdir}/source.json"
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"source":"srcval","target":"tarval","user":"usrval"}'
  
  they 'merge with target not yet created', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'usrval'
        merge: true
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"user":"usrval"}'
  
  they 'transform', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/target.json"
        content: '{"target":"transform","user":"overwrite"}'
      @file.json
        target: "#{tmpdir}/target.json"
        content: 'user': 'transform'
        merge: true
        transform: (json) ->
          json.target = "#{json.target} tarval"
          json.user = "#{json.user} usrval"
          json.transform = "tfmval"
          json
      .should.be.finally.containEql $status: true
      @fs.assert
        target: "#{tmpdir}/target.json"
        content: '{"target":"transform tarval","user":"transform usrval","transform":"tfmval"}'
  
  they 'pretty', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.json
        target: "#{tmpdir}/pretty.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: true
      @fs.assert
        target: "#{tmpdir}/pretty.json"
        content: '{\n  \"user\": {\n    \"preferences\": {\n      \"language\": \"french\"\n    }\n  }\n}'
  
  they 'pretty with user indentation', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.json
        target: "#{tmpdir}/pretty_0.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: 0
      @fs.assert
        target: "#{tmpdir}/pretty_0.json"
        content: '{"user":{"preferences":{"language":"french"}}}'
      @file.json
        target: "#{tmpdir}/pretty_1.json"
        content: 'user': 'preferences': 'language': 'french'
        pretty: 1
      @fs.assert
        target: "#{tmpdir}/pretty_1.json"
        content: '{\n \"user\": {\n  \"preferences\": {\n   \"language\": \"french\"\n  }\n }\n}'
