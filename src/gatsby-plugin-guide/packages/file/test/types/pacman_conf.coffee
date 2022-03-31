
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.pacman_conf', ->

  they 'empty values dont print values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        target: "#{tmpdir}/pacman.conf"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': ''
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'

  they 'boolean values dont print values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        target: "#{tmpdir}/pacman.conf"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'

  they 'rootdir with default target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        rootdir: "#{tmpdir}"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/etc/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'
