
nikita = require '@nikitajs/core/lib'
path = require 'path'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.cp', ->

  @timeout 20000
  
  they 'a remote file to a local file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm
        container: 'nikita_extract'
      @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: 'nikita_extract:/etc/apk/repositories'
        target: "#{tmpdir}/a_file"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/a_file"
      @docker.rm
        container: 'nikita_extract'

  they 'a remote file to a local directory', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm container: 'nikita_extract'
      @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: 'nikita_extract:/etc/apk/repositories'
        target: "#{tmpdir}"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/repositories"
      @docker.rm container: 'nikita_extract'

  they 'a local file to a remote file', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm container: 'nikita_extract'
      @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        volume: "#{tmpdir}:/root"
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: "#{__filename}"
        target: "nikita_extract:/root/a_file"
      $status.should.be.true()
      @docker.cp
        source: 'nikita_extract:/root/a_file'
        target: "#{tmpdir}"
      @fs.assert
        target: "#{tmpdir}/a_file"
      @docker.rm container: 'nikita_extract'

  they 'a local file to a remote directory', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @docker.rm container: 'nikita_extract'
      @docker.run
        name: 'nikita_extract'
        image: 'alpine'
        volume: "#{tmpdir}:/root"
        command: "whoami"
        rm: false
      {$status} = await @docker.cp
        source: "#{__filename}"
        target: "nikita_extract:/root"
      $status.should.be.true()
      @docker.cp
        source: "nikita_extract:/root/#{path.basename __filename}"
        target: "#{tmpdir}"
      @fs.assert
        target: "#{tmpdir}/#{path.basename __filename}"
      @docker.rm container: 'nikita_extract'
