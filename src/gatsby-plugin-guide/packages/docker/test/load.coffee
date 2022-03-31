
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.load', ->

  # timestamp ensures that hash of the built image will be unique and
  # image checksum is also unique

  they 'loads simple image', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.remove
        target: "#{tmpdir}/nikita_load.tar"
      @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      @docker.save
        image: 'nikita/load_test'
        tag: 'latest'
        output: "#{tmpdir}/nikita_load.tar"
      @docker.rmi
        image: 'nikita/load_test'
      {$status} = await @docker.load
        image: 'nikita/load_test'
        tag: 'latest'
        input: "#{tmpdir}/nikita_load.tar"
      $status.should.be.true()
      @docker.rmi
        image: 'nikita/load_test'

  they 'not loading if checksum', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.remove
        target: "#{tmpdir}/nikita_load.tar"
      {checksum} = await @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      @docker.save
        image: 'nikita/load_test'
        tag: 'latest'
        output: "#{tmpdir}/nikita_load.tar"
      {$status} = await @docker.load
        input: "#{tmpdir}/nikita_load.tar"
        checksum: checksum
      $status.should.be.false()

  they 'status not modified if same image', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.remove
        target: "#{tmpdir}/nikita_load.tar"
      @docker.rmi
        image: 'nikita/load_test:latest'
      @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/load.tar"
      @docker.load
        image: 'nikita/nikita_load:latest'
        input: "#{tmpdir}/load.tar"
      {$status} = await @docker.load
        image: 'nikita/nikita_load:latest'
        input: "#{tmpdir}/load.tar"
      $status.should.be.false()
