
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.pull', ->

  they 'pull image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
        force: true
      {$status} = await @docker.pull
        image: 'alpine'
      $status.should.be.true()

  they '$status not modified if same image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
        force: true
      @docker.pull
        image: 'alpine'
      {$status} = await @docker.pull
        image: 'alpine'
      $status.should.be.false()

  they 'pull specific image tag', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
        tag: 'edge'
        force: true
      {$status} = await @docker.pull
        image: 'alpine:edge'
      $status.should.be.true()
      {$status} = await @docker.pull
        image: 'alpine'
        tag: 'edge'
      $status.should.be.false()

  they.skip 'pull all tags', ({ssh}) ->
    # skipped because it is too long
    # we need to find an image with a few tags
    nikita
      $ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
        force: true
      {$status} = await @docker.pull
        image: 'alpine'
        all: true
      $status.should.be.true()
