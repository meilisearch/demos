
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.run', ->

  they 'simple command', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      {$status, stdout} = await @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
      $status.should.be.true()
      stdout.should.match /^test.*/
  
  they '--rm (flag option)', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test_rm'
      {stdout} = await @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        container: 'nikita_test_rm'
        rm: false
      stdout.should.match /^test.*/
      @docker.rm
        force: true
        container: 'nikita_test_rm'

  they 'unique option from array option', ({ssh}) ->
    @timeout 0
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_unique'
        force: true
      @docker.run
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_unique'
        detach: true
        rm: false
      @docker.rm
        force: true
        container: 'nikita_test_unique'

  they 'array options', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test_array'
      @docker.run
        image: 'httpd'
        port: [ '500:80', '501:81' ]
        container: 'nikita_test_array'
        detach: true
        rm: false
      # .wait_connect
      #   host: ipadress of docker, docker-machine...
      #   port: 500
      @docker.rm
        force: true
        container: 'nikita_test_array'

  they 'existing container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test'
      @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      {$status} = await @docker.run
        command: "echo test"
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      $status.should.be.false()
      @docker.rm
        force: true
        container: 'nikita_test'

  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test'
      @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      {$status} = await @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      $status.should.be.false()
      @docker.rm
        force: true
        container: 'nikita_test'
