
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.config.device.delete', ->

  they 'Fail if the device does not exist', ({ssh}) -> ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-delete-1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-config-device-delete-1'
      {$status} = await @lxc.config.device.delete
        device: 'nondevice'
        container: 'nikita-config-device-delete-1'
      $status.should.be.false()

  they 'Delete a device', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-delete-2'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-config-device-delete-2'
      @lxc.config.device
        container: 'nikita-config-device-delete-2'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status} = await @lxc.config.device.delete
        device: 'test'
        container: 'nikita-config-device-delete-2'
      $status.should.be.true()
