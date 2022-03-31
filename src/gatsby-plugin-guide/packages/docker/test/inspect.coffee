
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.inspect', ->

  they 'one running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_inspect'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_inspect'
      {info} = await @docker.inspect
        container: 'nikita_test_inspect'
      info.Name.should.eql '/nikita_test_inspect'
      @docker.rm
        container: 'nikita_test_inspect'
        force: true

  they 'two running containers', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
      @docker.tools.service [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], image: 'httpd'
      {info} = await @docker.inspect
        container: [
          'nikita_test_inspect_1'
          'nikita_test_inspect_2'
        ]
      names = info.map (i) -> i.Name
      names.should.eql [
        '/nikita_test_inspect_1'
        '/nikita_test_inspect_2'
      ]
      @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
