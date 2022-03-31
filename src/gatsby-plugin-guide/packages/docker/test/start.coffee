
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.start', ->

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_start'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_start'
      @docker.stop
        container: 'nikita_test_start'
      {$status} = await @docker.start
        container: 'nikita_test_start'
      $status.should.be.true()
      @docker.rm
        container: 'nikita_test_start'
        force: true

  they 'on started container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_start'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_start'
      @docker.stop
        container: 'nikita_test_start'
      @docker.start
        container: 'nikita_test_start'
      {$status} = await @docker.start
        container: 'nikita_test_start'
      $status.should.be.false()
      @docker.rm
        container: 'nikita_test_start'
        force: true
