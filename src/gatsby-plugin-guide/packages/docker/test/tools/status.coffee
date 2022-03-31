
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require '../test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.tools.status', ->

  they 'on stopped  container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_status'
        force: true
      @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        name: 'nikita_status'
      {$status} = await @docker.tools.status
        container: 'nikita_status'
      $status.should.be.false()
      @docker.rm
        container: 'nikita_status'
        force: true

  they 'on running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_status'
        force: true
      @docker.tools.service
        image: 'httpd'
        port: [ '500:80' ]
        container: 'nikita_status'
      {$status} = await @docker.tools.status
        container: 'nikita_status'
      $status.should.be.true()
      @docker.rm
        container: 'nikita_status'
        force: true
