
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.init', ->
  
  describe 'schema', ->
  
    it 'Container name is between 1 and 63 characters long', ->
      nikita
      .lxc.init
        image: "images:#{images.alpine}"
        container: "very-long-long-long-long-long-long-long-long-long-long-long-long-long-name"
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `lxc.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name accepts letters, numbers and dashes from the ASCII table', ->
      nikita
      .lxc.init
        image: "images:#{images.alpine}"
        container: 'my_name'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `lxc.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name must not start with a digit', ->
      nikita.lxc.init
        image: "images:#{images.alpine}"
        container: '1u'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `lxc.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
    
    it 'Container name must not start with a dash', ->
      nikita.lxc.init
        image: "images:#{images.alpine}"
        container: '-u1'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `lxc.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name is not end with a dash', ->
      nikita
      .lxc.init
        image: "images:#{images.alpine}"
        container: 'u1-'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `lxc.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
  describe 'container', ->
  
    they 'Init a new container', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-1', force: true
        await @clean()
        {$status} = await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-1'
        $status.should.be.true()
        await @clean()
        
    they 'Config `start`', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-2', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-2'
          start: true
        {$status} = await @lxc.running
          container: 'nikita-init-2'
        $status.should.be.true()
        await @clean()
  
    they 'Validate name', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-3', force: true
        await @clean()
        {$status} = await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-3'
        $status.should.be.true()
        await @clean()
  
    they 'Container already exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-4', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-4'
        {$status} = await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-4'
        $status.should.be.false()
        await @clean()
    
  describe 'vm', ->
    return unless tags.lxd_vm

    they 'Init new VM', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-vm1', force: true
        await @clean()
        {$status} = await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-vm1'
          vm: true
        $status.should.be.true()
        await @clean()
  
    they 'VM already exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-init-vm2', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-vm2'
          vm: true
        {$status} = await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-init-vm2'
          vm: true
        $status.should.be.false()
        await @clean()
