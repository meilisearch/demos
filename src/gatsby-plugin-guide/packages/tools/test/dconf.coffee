
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.tools_dconf

describe 'tools.dconf', ->
  
  # Note, dconf inside docker fail to work and print
  # "error: Cannot autolaunch D-Bus without X11 $DISPLAY"
  # To make it work, we config `dbus-launch` with a docket file path with
  # `unix:path`, place the configuration file in
  # "/etc/dbus-1/session.d/dbus.conf"
  # and launch `dbus-launch` in `run.sh`
  
  they 'set single config', ({env, ssh}) ->
    nikita
      $ssh: ssh
      $env: env
    , ->
      await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
      {$status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
      $status.should.be.true()
      {$status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
      $status.should.be.false()
      await @execute.assert
        command: 'dconf read /org/gnome/desktop/datetime/automatic-timezone'
        content: 'true'
        trim: true
  
  they 'set multiple configs', ({env, ssh}) ->
    nikita
      $ssh: ssh
      $env: env
    , ->
      await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
          '/org/gnome/desktop/peripherals/touchpad/click-method': 1
      {$status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
          '/org/gnome/desktop/peripherals/touchpad/click-method': 2
      $status.should.be.true()
      {$status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
          '/org/gnome/desktop/peripherals/touchpad/click-method': 2
      $status.should.be.true()
      {$status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
          '/org/gnome/desktop/peripherals/touchpad/click-method': 2
      $status.should.be.false()
      await @execute.assert
        command: 'dconf read /org/gnome/desktop/datetime/automatic-timezone'
        content: 'false'
        trim: true
      await @execute.assert
        command: 'dconf read /org/gnome/desktop/peripherals/touchpad/click-method'
        content: 2
        trim: true
  
