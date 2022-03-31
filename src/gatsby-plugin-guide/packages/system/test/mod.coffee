
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'system.mod', ->

  they 'activate a module', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules: 'module_a'
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      {$status} = await @system.mod
        load: false
        modules: 'module_a'
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\n"

  they 'activate multiple modules', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\nmodule_b\n"

  they 'desactivate a module', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
          'module_c': true
        target: "#{tmpdir}/mods/modules.conf"
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': false
          'module_c': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\nmodule_c\n"
