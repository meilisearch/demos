
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.yaml', ->

  they 'stringify an object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.yaml
        content: user: preference: color: 'rouge'
        target: "#{tmpdir}/user.yml"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    color: rouge\n'

  they 'merge an object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: english\n'
      {$status} = await @file.yaml
        content: user: preference: language: 'french'
        target: "#{tmpdir}/user.yml"
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: french\n'

  they 'discard undefined and null', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.yaml
        content: user: preference: color: 'violet', age: undefined, gender: null
        target: "#{tmpdir}/user.yml"
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    color: violet\n'

  they 'remove null within merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    country: france\n    language: lovelynode\n    color: rouge\n'
      {$status} = await @file.yaml
        content: user: preference:
          color: 'rouge'
          language: null
        target: "#{tmpdir}/user.yml"
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    country: france\n    color: rouge\n'

  they 'disregard undefined within merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: node\n    name:    toto\n'
      {$status} = await @file.yaml
        target: "#{tmpdir}/user.yml"
        content: user: preference:
          language: 'node'
          name: null
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: node\n'

  they 'disregard undefined within merge', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: node\n  name: toto\ngroup: hadoop_user\n'
      {$status} = await @file.yaml
        content:
          group: null
        target: "#{tmpdir}/user.yml"
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.yml"
        content: 'user:\n  preference:\n    language: node\n  name: toto\n'
