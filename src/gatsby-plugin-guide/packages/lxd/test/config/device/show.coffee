
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.config.device.show', ->

  they 'config output', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-show-1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-config-show-1'
      @lxc.config.device
        container: 'nikita-config-show-1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status, properties} = await @lxc.config.device.show
        container: 'nikita-config-show-1'
        device: 'test'
      $status.should.be.true()
      properties.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
