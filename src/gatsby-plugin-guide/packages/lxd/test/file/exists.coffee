
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.file.exists', ->

  they 'when present', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-exists-1', force: true
      await @clean()
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-file-exists-1'
        start: true
      @execute
        command: "lxc exec nikita-file-exists-1 -- touch /root/a_file"
      {exists} = await @lxc.file.exists
        container: 'nikita-file-exists-1'
        target: '/root/a_file'
      exists.should.be.true()
      await @clean()

  they 'when missing', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-exists-2', force: true
      await @clean()
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-file-exists-2'
        start: true
      {exists} = await @lxc.file.exists
        container: 'nikita-file-exists-2'
        target: '/root/a_file'
      exists.should.be.false()
      await @clean()
  
