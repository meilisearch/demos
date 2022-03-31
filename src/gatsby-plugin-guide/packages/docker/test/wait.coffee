
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker or tags.docker_volume

describe 'docker.wait', ->

  they 'container already started', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_wait'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_wait'
      setTimeout =>
        @docker.stop
          container: 'nikita_test_wait'
      , 50
      {$status} = await nikita
        $ssh: ssh
        docker: docker
      .docker.wait
        container: 'nikita_test_wait'
      $status.should.be.true()
