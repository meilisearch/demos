
path = require 'path'
runner = require '@nikitajs/lxd-runner'

# Note:
# Dec 4th, 2020: upgrading Atom to 1.52.0 or 1.53.0 on centos7 20201203_07:08
# lead to an error while running `apm`
# "Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found"
# issue is open on the moment - https://github.com/atom/atom/issues/21497

runner
  cwd: '/nikita/packages/tools'
  container: 'nikita-tools-apm'
  logdir: path.resolve __dirname, './logs'
  cluster:
    containers:
      'nikita-tools-apm':
        image: 'images:centos/7'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/apm/test.coffee'
          'raw.idmap': if process.env['NIKITA_LXD_IN_VAGRANT']
          then 'both 1000 0'
          else "both #{process.getuid()} 0"
        disk:
          nikitadir:
            path: '/nikita'
            source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
        ssh: enabled: true
    provision_container: ({config}) ->
      await @lxc.exec
        $header: 'Node.js'
        container: config.container
        command: '''
        if command -v node ; then exit 42; fi
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
        . ~/.bashrc
        nvm install node
        '''
        trap: true
        code_skipped: 42
      await @lxc.exec
        $header: 'SSH keys'
        container: config.container
        command: """
        mkdir -p /root/.ssh && chmod 700 /root/.ssh
        if [ ! -f /root/.ssh/id_rsa ]; then
          ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
          cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
        fi
        """
        trap: true
      await @lxc.exec
        $header: 'Install Atom'
        container: config.container
        command: """
        apm -v | grep apm && exit 42
        yum install -y wget
        wget https://github.com/atom/atom/releases/download/v1.51.0/atom.x86_64.rpm
        yum install -y atom.x86_64.rpm
        """
        trap: true
        code_skipped: 42
.catch (err) ->
  console.error err
