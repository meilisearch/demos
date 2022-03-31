
nikita = require '@nikitajs/core/lib'
{tags, config, ruby} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_rubygems

describe 'tools.rubygems.remove', ->

  they 'remove an existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.true()

  they 'remove a non existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
      await @tools.rubygems.remove
        name: 'execjs'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.false()

  they 'remove multiple versions', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.true()
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.false()
