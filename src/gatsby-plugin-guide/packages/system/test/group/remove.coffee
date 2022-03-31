
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.system_group

describe 'system.group.remove', ->
  
  they 'handle status', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @system.user.remove 'toto'
      @system.group.remove 'toto'
      @system.group 'toto'
      {$status} = await @system.group.remove 'toto'
      $status.should.be.true()
      {$status} = await @system.group.remove 'toto'
      $status.should.be.false()
