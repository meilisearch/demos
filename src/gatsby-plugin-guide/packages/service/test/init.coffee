
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.service_systemctl

describe 'service.init', ->
  
  @timeout 60000

  they 'init file with target and source (default)', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @service.remove 'cronie'
      @fs.remove
        target: '/etc/init.d/crond'
      @service.init
        source: "#{__dirname}/crond.hbs"
        target: '/etc/init.d/crond'
      @fs.assert '/etc/init.d/crond'
  
  they 'init file with source only (default)', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service.remove 'cronie'
      @fs.remove
        target: '/etc/init.d/crond'
      @service.init
        source: "#{__dirname}/crond.hbs"
      @fs.assert '/etc/init.d/crond'
  
  they 'init file with source and name (default)', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service.remove 'cronie'
      @fs.remove
        target: '/etc/init.d/crond'
      @service.init
        source: "#{__dirname}/crond.hbs"
        name: 'crond-name'
      @fs.assert '/etc/init.d/crond-name'
  
  describe 'daemon-reload', ->
  
    they 'with systemctl sysv-generator', ({ssh}) ->
      nikita
        $ssh: ssh
        $if_os: name: ['redhat','centos'], version: '7'
      , ->
        @service.remove 'cronie'
        @service.install 'cronie'
        @fs.remove
          target: '/etc/init.d/crond'
        @execute
          command: 'systemctl daemon-reload;systemctl reset-failed'
        @service.init
          source: "#{__dirname}/crond.hbs"
          name: 'crond'
        @fs.assert '/etc/init.d/crond'
        @service.start
          name: 'crond'
        @service.start
          name: 'stop'

    they 'with systemctl systemd script', ({ssh}) ->
      nikita
        $ssh: ssh
        $if_os: name: ['redhat','centos'], version: '7'
      , ->
        @service.remove 'cronie'
        @service.install 'cronie'
        @fs.remove
          target: '/etc/init.d/crond'
        @fs.remove
          target: '/usr/lib/systemd/system/crond.service'
        {$status} = await @service.init
          source: "#{__dirname}/crond-systemd.hbs"
          context: description: 'Command Scheduler Test 1'
          target: '/usr/lib/systemd/system/crond.service'
        $status.should.be.true()
        @fs.assert '/usr/lib/systemd/system/crond.service'
        @service.start
          name: 'crond'
