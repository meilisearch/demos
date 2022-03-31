
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker or tags.docker_volume

describe 'docker.volume_create', ->

  they 'a named volume', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.volume_rm
        name: 'my_volume'
      {$status} = await @docker.volume_create
        name: 'my_volume'
      $status.should.be.true()
      {$status} = await @docker.volume_create
        name: 'my_volume'
      $status.should.be.false()
      @docker.volume_rm
        name: 'my_volume'
