
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require '../test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.tools.checksum', ->

  they 'checksum on existing repository', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'nikita/checksum'
      {image} = await @docker.build
        image: 'nikita/checksum'
        content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
      {checksum} = await @docker.tools.checksum
        image: 'nikita/checksum'
        tag: 'latest'
      checksum.should.startWith "sha256:#{image}"
      @docker.rmi
        image: 'nikita/checksum'

  they 'checksum on not existing repository', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      {checksum} = await @docker.tools.checksum
        image: 'nikita/invalid_checksum'
        tag: 'latest'
      (checksum is undefined).should.be.true()
