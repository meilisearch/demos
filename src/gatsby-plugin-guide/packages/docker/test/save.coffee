
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.save', ->

  they 'saves a simple image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.build
        image: 'nikita/load_test'
        content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
      {$status} = await @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      $status.should.be.true()

  they.skip 'status not modified', ({ssh}) ->
    # For now, there are no mechanism to compare the checksum between an old and a new target
    nikita
      $ssh: ssh
      docker: docker
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.build
        image: 'nikita/load_test'
        content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
      @docker.save
        debug: true
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      {$status} = await @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      $status.should.be.false()
