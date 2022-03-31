
nikita = require '@nikitajs/core/lib'
{tags, config, ruby} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_rubygems

describe 'tools.rubygems.install', ->

  they 'install a non existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
      $status.should.be.true()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'bypass existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.install
        name: 'execjs'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'install multiple versions', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      $status.should.be.false()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'local gem from file', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.8.1'
        cwd: "#{tmpdir}"
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/execjs-2.8.1.gem"
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.8.1'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'

  they 'local gem from glob', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.rubygems.remove
        name: 'execjs'
      await @tools.rubygems.fetch
        name: 'execjs'
        version: '2.7.0'
        cwd: "#{tmpdir}"
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/*.gem"
      $status.should.be.true()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        source: "#{tmpdir}/*.gem"
      $status.should.be.false()
      {$status} = await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      $status.should.be.false()
      await @tools.rubygems.remove
        name: 'execjs'
