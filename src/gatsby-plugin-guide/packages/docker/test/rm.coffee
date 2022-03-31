
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.rm', ->

  they 'status', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_rm'
      @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        name: 'nikita_rm'
        rm: false
      {$status} = await @docker.rm
        container: 'nikita_rm'
      $status.should.be.true()
      {$status} = await @docker.rm
        container: 'nikita_rm'
      $status.should.be.false()

  they 'remove live container (no force)', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: docker
    , ->
      try
        @docker.rm
          container: 'nikita_rm'
          force: true
        @docker.tools.service
          image: 'httpd'
          port: '499:80'
          container: 'nikita_rm'
        await @docker.rm
          container: 'nikita_rm'
        throw Error 'Oh no'
      catch err
        err.message.should.eql 'Container must be stopped to be removed without force'
      finally
        @docker.stop
          container: 'nikita_rm'
        @docker.rm
          container: 'nikita_rm'

  they 'remove live container (with force)', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: docker
    , ->
      await @docker.rm
        container: 'nikita_rm'
        force: true
      await @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_rm'
      {$status} = await @docker.rm
        container: 'nikita_rm'
        force: true
      $status.should.be.true()
