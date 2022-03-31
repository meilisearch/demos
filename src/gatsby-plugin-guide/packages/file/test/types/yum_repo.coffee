
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.yum_repo', ->

  they 'generate from content object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.1":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.1":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/test.repo"

  they 'merge with content object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.2":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.2":
            'gpgcheck': '0'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/test.repo"

  they 'write to default repository dir', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.3":
            'name': 'CentOS'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/test.repo"
        content: """
          [test-repo-0.0.3]
          name = CentOS
          mirrorlist = http://test/?infra=$infra
          baseurl = http://mirror.centos.org\n
        """
        trim: true

  they 'default from source with content', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/CentOS-nikita.repo"
        source: "#{__dirname}/../resources/CentOS-nikita.repo"
        local: true
        content:
          "test-repo-0.0.4":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/CentOS-nikita.repo"
