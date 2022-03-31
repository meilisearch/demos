
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.config.device.exists', ->

  they 'Device does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-exists-1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-config-device-exists-1'
      {exists} = await @lxc.config.device.exists
        container: 'nikita-config-device-exists-1'
        device: 'test'
      exists.should.be.false()

  they 'Device exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-exists-2'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-config-device-exists-2'
      @lxc.config.device
        container: 'nikita-config-device-exists-2'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {exists} = await @lxc.config.device.exists
        container: 'nikita-config-device-exists-2'
        device: 'test'
      exists.should.be.true()
