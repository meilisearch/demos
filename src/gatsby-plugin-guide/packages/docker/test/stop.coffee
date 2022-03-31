
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.stop', ->

  they 'on running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_stop'
      {$status} = await @docker.stop
        container: 'nikita_test_stop'
      $status.should.be.true()
      @docker.rm
        container: 'nikita_test_stop'
        force: true

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_stop'
      @docker.stop
        container: 'nikita_test_stop'
      {$status} = await @docker.stop
        container: 'nikita_test_stop'
      $status.should.be.false()
      @docker.rm
        container: 'nikita_test_stop'
        force: true
