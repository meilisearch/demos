
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require '../test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.compose', ->

  @timeout 90000

  they 'up from content', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_docker_compose_up_content'
        force: true
      {$status} = await @docker.compose.up
        content:
          compose:
            image: 'httpd'
            container_name: 'nikita_docker_compose_up_content'
            ports: ['499:80']
      $status.should.be.true()
      {$status} = await @execute
        command: 'ping dind -c 1'
        code_skipped: [2,68]
      @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 499
      @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 499
      @docker.rm
        container: 'nikita_docker_compose_up_content'
        force: true
  
  they 'up from content to file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm
        container: 'nikita_docker_docker_compose_up_content_to_file'
        force: true
      {$status} = await @docker.compose
        content:
          compose:
            image: 'httpd'
            container_name: 'nikita_docker_docker_compose_up_content_to_file'
            ports: ['499:80']
        target: "#{tmpdir}/docker_compose_up_content_to_file/docker-compose.yml"
      $status.should.be.true()
      {$status} = await @execute
        command: 'ping dind -c 1'
        code_skipped: [2,68]
      @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 499
      @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 499
      @docker.rm
        container: 'nikita_docker_docker_compose_up_content_to_file'
        force: true

  they 'up from file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm
        container: 'nikita_docker_compose_up_file'
        force: true
      @file.yaml
        content:
          compose:
            image: 'httpd'
            container_name: 'nikita_docker_compose_up_file'
            ports: ['499:80']
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      @docker.compose
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      {$status} = await @execute
        command: 'ping dind -c 1'
        code_skipped: [2,68]
      @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 499
      @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 499
      @docker.rm
        container: 'nikita_docker_compose_up_file'
        force: true
  
  they 'up with service name', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm
        container: 'nikita_docker_compose_up_service'
        force: true
      @file.yaml
        content:
          compose:
            image: 'httpd'
            container_name: 'nikita_docker_compose_up_service'
            ports: ['499:80']
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      @docker.compose
        service: 'compose'
        target: "#{tmpdir}/docker_compose_up_file/docker-compose.yml"
      {$status} = await @execute
        command: 'ping dind -c 1'
        code_skipped: [2,68]
      @network.tcp.wait
        $if: $status # Inside docker compose
        host: 'dind'
        port: 499
      @network.tcp.wait
        $unless: $status # Inside host node
        host: '127.0.0.1'
        port: 499
      @docker.rm
        container: 'nikita_docker_compose_up_service'
        force: true
  
  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm
        container: 'nikita_docker_compose_idem'
        force: true
      @file.yaml
        content:
          compose:
            image: 'httpd'
            container_name: 'nikita_docker_compose_idem'
            ports: ['499:80']
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      @docker.compose
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      @network.tcp.wait
        host: 'dind'
        port: 499
      {$status} = await @docker.compose
        target: "#{tmpdir}/nikita_docker_compose_idem/docker-compose.yml"
      $status.should.be.false()
      @docker.rm
        container: 'nikita_docker_compose_idem'
        force: true
