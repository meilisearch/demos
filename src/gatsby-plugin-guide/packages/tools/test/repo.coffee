
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.tools_repo

describe 'tools.repo', ->

  @timeout 200000

  they 'Write with source option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.mkdir "#{tmpdir}/repo"
      @file
        target: "#{tmpdir}/CentOS.repo"
        content: """
        [base]
        name=CentOS-$releasever - Base
        mirrorlist=http://localhost?release=$releasever&arch=$basearch&repo=os&infra=$infra
        baseurl=http://localhost/centos/$releasever/os/$basearch/
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      {$status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      $status.should.be.true()
      {$status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      {$status} = await $status.should.be.false()
      @fs.assert "#{tmpdir}/repo/centos.repo"
  
  they 'Write with content option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.mkdir "#{tmpdir}/repo"
      {$status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/repo/centos.repo"
        content: '[base]\nname = CentOS-$releasever - Base\nbaseurl = http://mirror.centos.org/centos/$releasever/os/$basearch/\ngpgcheck = 0\n'
  
  they 'delete files with clean option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/source/CentOS.repo"
        content: """
          [base]
          name=CentOS-$releasever - Base
          mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
          baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
          gpgcheck=1
          gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
      {$status} = await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
        clean: 'test*'
      $status.should.be.false()
      await @file.touch
        target: "#{tmpdir}/target/test.repo"
      {$status} = await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
        clean: "test*"
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/target/test.repo"
        not: true
  
  they 'Download GPG Keys option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/linuxtech.repo"
        content: """
        [linuxtech-release]
        name=LinuxTECH.NET el6 main repo
        baseurl=http://linuxsoft.cern.ch/linuxtech/el6/release/
        mirrorlist=http://pkgrepo.linuxtech.net/el6/release/mirrorlist.txt
        mirrorlist_expire=7d
        enabled=1
        gpgcheck=1
        gpgkey=http://pkgrepo.linuxtech.net/el6/release/RPM-GPG-KEY-LinuxTECH.NET
        """
      await @tools.repo
        source: "#{tmpdir}/linuxtech.repo"
        gpg_dir: "#{tmpdir}"
        update: false
      await @fs.assert "#{tmpdir}/RPM-GPG-KEY-LinuxTECH.NET"
  
  they 'Download repo from remote location', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @fs.remove '/etc/yum.repos.d/linuxtech.repo'
      {$status} = await @tools.repo
        source: "http://pkgrepo.linuxtech.net/el6/release/linuxtech.repo"
      $status.should.be.true()
      {$status} = await @tools.repo
        source: "http://pkgrepo.linuxtech.net/el6/release/linuxtech.repo"
      $status.should.be.false()
      await @fs.assert '/etc/yum.repos.d/linuxtech.repo'

  they 'config `update` is `false` (default)', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @fs.remove '/etc/yum.repos.d/mongodb.repo'
      await @service.remove 'mongodb-org-shell'
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.2':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
      await @service.install
        name: 'mongodb-org-shell'
      await @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      $status.should.be.false()
      await @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"

  they 'config `update` is `true`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @fs.remove '/etc/yum.repos.d/mongodb.repo'
      await @fs.remove '/etc/pki/rpm-gpg/server-3.2.asc'
      await @fs.remove '/etc/pki/rpm-gpg/server-3.4.asc'
      await @service.remove 'mongodb-org-shell'
      await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.2':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
      await @service.install
        name: 'mongodb-org-shell'
      await @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        update: true
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        update: true
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      $status.should.be.false()
      await @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.4'"
