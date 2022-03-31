
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'system.user.remove', ->
  
  describe 'schema', ->
    
    return unless tags.api
    
    it 'default argument', ->
      {config} = await nikita.system.user.remove 'toto', ({config}) ->
        config: config
      config.name.should.eql 'toto'
      
  describe 'usage', ->
    
    return unless tags.system_user
  
    they 'handle status', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @system.user.remove 'toto'
        @system.group.remove 'toto'
        @system.user 'toto'
        {$status} = await @system.user.remove 'toto'
        $status.should.be.true()
        {$status} = await @system.user.remove 'toto'
        $status.should.be.false()
