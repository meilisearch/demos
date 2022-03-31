
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.kill', ->

  they 'running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_kill'
        force: true
      @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.true()

  they 'status not modified (previously killed)', ({ssh}) ->
    @timeout 120000
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_kill'
        force: true
      @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_kill'
      @docker.kill
        container: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.false()

  they 'status not modified (not living)', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_kill'
      @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        name: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.false()
      @docker.rm
        container: 'nikita_test_kill'
