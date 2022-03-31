
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'tools.git', ->

  they 'clones repo into new dir', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      $status.should.be.true()
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      $status.should.be.false()

  they 'honores revision', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      $status.should.be.true()
      {$status} = await @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
        revision: 'v0.0.1'
      $status.should.be.false()

  they 'preserves existing directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @tools.extract
        source: "#{__dirname}/resources/repo.git.zip"
        target: "#{tmpdir}"
      @fs.mkdir
        target: "#{tmpdir}/my_repo"
      @tools.git
        source: "#{tmpdir}/repo.git"
        target: "#{tmpdir}/my_repo"
      .should.be.rejectedWith
        message: 'Not a git repository'
