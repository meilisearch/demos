
utils = require '../src/utils'
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.system_cgroups

describe 'system.cgroups', ->
  
  describe 'generate without merge', ->
    
    mounts = [
      { type: 'cpuset', path: '/cgroup/cpuset' }
      { type: 'cpu', path: '/cgroup/cpu' }
      { type: 'cpuacct', path: '/cgroup/cpuacct' }
      { type: 'memory', path: '/cgroup/memory' }
      { type: 'devices', path: '/cgroup/devices' }
    ]
    groups =
      toto:
        perm:
          admin: uid: 'toto', gid: 'toto'
          task: uid: 'toto', gid: 'toto'
        cpu:
          'cpu.rt_period_us': '"1000000"'
          'cpu.rt_runtime_us': '"0"'
          'cpu.cfs_period_us': '"100000"'
    def =
      perm:
        admin:
          uid: 'toto'
          gid: 'toto'
        task:
          uid: 'toto'
          gid: 'toto'
      cpu:
        'cpu.rt_period_us': '"1000000"'
        'cpu.rt_runtime_us': '"0"'
        'cpu.cfs_period_us': '"100000"'
    
    they 'simple mount group configuration file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_mount_only.cgconfig.conf"
          mode: 0o0754
          mounts: mounts
          merge:false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/a_file_mount_only.cgconfig.conf"
          content:  """
            mount {
              cpuset = /cgroup/cpuset;
              cpu = /cgroup/cpu;
              cpuacct = /cgroup/cpuacct;
              memory = /cgroup/memory;
              devices = /cgroup/devices;
            }
          """
    
    they 'simple cgroup configuration file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_cgroup_only.cgconfig.conf"
          mode: 0o0754
          groups: groups
          merge: false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/a_file_cgroup_only.cgconfig.conf"
          content: """
            group toto {
              perm {
                admin {
                  uid = toto;
                  gid = toto;
                }
                task {
                  uid = toto;
                  gid = toto;
                }
              }
              cpu {
                cpu.rt_period_us = "1000000";
                cpu.rt_runtime_us = "0";
                cpu.cfs_period_us = "100000";
              }
            }
          """
      
    they 'default only configuration file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_default_only.cgconfig.conf"
          mode: 0o0754
          default: def
          merge: false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/a_file_default_only.cgconfig.conf"
          content: """
            default {
              perm {
                admin {
                  uid = toto;
                  gid = toto;
                }
                task {
                  uid = toto;
                  gid = toto;
                }
              }
              cpu {
                cpu.rt_period_us = "1000000";
                cpu.rt_runtime_us = "0";
                cpu.cfs_period_us = "100000";
              }
            }
          """
    
    they 'complete configuration file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_complete.cgconfig.conf"
          mode: 0o0754
          default: def
          groups: groups
          mounts: mounts
          merge: false
        $status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/a_file_complete.cgconfig.conf"
          content: """
            mount {
              cpuset = /cgroup/cpuset;
              cpu = /cgroup/cpu;
              cpuacct = /cgroup/cpuacct;
              memory = /cgroup/memory;
              devices = /cgroup/devices;
            }
            group toto {
              perm {
                admin {
                  uid = toto;
                  gid = toto;
                }
                task {
                  uid = toto;
                  gid = toto;
                }
              }
              cpu {
                cpu.rt_period_us = "1000000";
                cpu.rt_runtime_us = "0";
                cpu.cfs_period_us = "100000";
              }
            }
            default {
              perm {
                admin {
                  uid = toto;
                  gid = toto;
                }
                task {
                  uid = toto;
                  gid = toto;
                }
              }
              cpu {
                cpu.rt_period_us = "1000000";
                cpu.rt_runtime_us = "0";
                cpu.cfs_period_us = "100000";
              }
            }
          """

    they 'status not modifed', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @system.cgroups
          target: "#{tmpdir}/a_file_complete.cgconfig.conf"
          mode: 0o0754
          default: def
          groups: groups
          mounts: mounts
          merge: false
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_complete.cgconfig.conf"
          mode: 0o0754
          default: def
          groups: groups
          mounts: mounts
          merge: false
        $status.should.be.false()

  describe 'generate with merge', ->
    
    mounts = [
        type: 'cpuset'
        path: '/cgroup/cpuset'
      ,
        type: 'cpu', path: '/cgroup/cpu'
      ,
        type: 'cpuacct', path: '/cgroup/cpuacct'
      ,
        type: 'memory', path: '/cgroup/memory'
      ,
        type: 'devices', path: '/cgroup/devices'
      ]
    groups =
      toto:
        perm:
          admin: uid: 'toto', gid: 'toto'
          task: uid: 'toto', gid: 'toto'
        cpu:
          'cpu.rt_period_us': '"1000000"'
          'cpu.rt_runtime_us': '"0"'
          'cpu.cfs_period_us': '"100000"'
    def =
      perm:
        admin: uid: 'toto', gid: 'toto'
        task: uid: 'toto', gid: 'toto'
      cpu:
        'cpu.rt_period_us': '"1000000"'
        'cpu.rt_runtime_us': '"0"'
        'cpu.cfs_period_us': '"100000"'
    
    they 'read mount from system and merge group', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_merge_mount_groups.cgconfig.conf"
          mode: 0o0754
          groups: groups
          merge: true
        $status.should.be.true()
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/a_file_merge_mount_groups.cgconfig.conf"
          encoding: 'utf8'
        data = utils.cgconfig.parse data
        data.mounts.should.not.be.empty()
        for name, group of groups
          data.groups[name].should.eql group
    
    they 'status not modified', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        @system.cgroups
          target: "#{tmpdir}/a_file_merge_mount_groups.cgconfig.conf"
          mode: 0o0754
          groups: groups
          merge: true
        {$status} = await @system.cgroups
          target: "#{tmpdir}/a_file_merge_mount_groups.cgconfig.conf"
          mode: 0o0754
          groups: groups
          merge: true
        $status.should.be.false()

  describe 'centos only', ->
    
    they 'get cgroups attributes', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {cgroups} = await @system.cgroups
          target: "#{tmpdir}/a_file_merge_mount_groups.cgconfig.conf"
          mode: 0o0754
          groups: toto:
            perm:
              admin: uid: 'toto', gid: 'toto'
              task: uid: 'toto', gid: 'toto'
            cpu:
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
          merge: true
        cgroups['cpu_path'].should.match /^((\/sys\/fs\/cgroup\/cpu)|(\/cgroups\/cpu))/
        cgroups['mount'].should.match /^((\/sys\/fs\/cgroup)|(\/cgroups))/
