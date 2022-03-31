
nikita = require '@nikitajs/core/lib'
require '@nikitajs/service/src'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.tools_iptables

describe 'tools.iptables', ->

  they 'insert a rull after existing', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @service
        name: 'iptables-services'
        srv_name: 'iptables'
        state: ['started']
      after = chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo'
      {$status} = await @tools.iptables
        $sudo: true
        rules: [
          chain: 'INPUT', after: after, jump: 'ACCEPT', dport: 22, protocol: 'tcp'
        ]
      $status.should.be.true()
      {stdout} = await @execute
        sudo: true
        command: 'iptables -S'
      stdout.should.containEql [
        '-A INPUT -i lo -j ACCEPT'
        '-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT'
      ].join '\n'
