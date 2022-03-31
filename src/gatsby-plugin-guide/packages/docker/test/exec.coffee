
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.exec', ->

  they 'simple command', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      await @docker.rm
        container: 'nikita_test_exec'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {$status, stdout} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'echo toto'
      $status.should.be.true()
      stdout.trim().should.eql 'toto'
      await @docker.rm
        container: 'nikita_test_exec'
        force: true

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      try
        @docker.rm
          container: 'nikita_test_exec'
          force: true
        @docker.tools.service
          image: 'httpd'
          container: 'nikita_test_exec'
        @docker.stop
          container: 'nikita_test_exec'
        await @docker.exec
          container: 'nikita_test_exec'
          command: 'echo toto'
        throw Error 'Oh no'
      catch err
        err.message.should.match /Container [a-z0-9]+ is not running/
      finally
        @docker.rm
          container: 'nikita_test_exec'
          force: true

  they 'on non existing container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.exec
        container: 'nikita_fake_container'
        command: 'echo toto'
      .should.be.rejectedWith 'Error: No such container: nikita_fake_container'

  they 'skip exit code', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_exec'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {$status} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'toto'
        code_skipped: 126
      $status.should.be.false()
      @docker.rm
        container: 'nikita_test_exec'
        force: true
