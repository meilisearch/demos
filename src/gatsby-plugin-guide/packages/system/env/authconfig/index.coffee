
path = require 'path'
runner = require '@nikitajs/lxd-runner'

runner
  cwd: '/nikita/packages/system'
  container: 'nikita-system-authconfig'
  logdir: path.resolve __dirname, './logs'
  cluster:
    containers:
      'nikita-system-authconfig':
        image: 'images:centos/7'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/system/env/authconfig/test.coffee'
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
        $header: 'Package'
        container: config.container
        command: 'yum install -y authconfig'
.catch (err) ->
  console.error err
