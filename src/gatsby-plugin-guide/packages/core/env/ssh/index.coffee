
path = require 'path'
runner = require '@nikitajs/lxd-runner'

runner
  cwd: '/nikita/packages/core'
  container: 'nikita-core-ssh'
  logdir: path.resolve __dirname, './logs'
  cluster:
    containers:
      'nikita-core-ssh':
        image: 'images:centos/7'
        # image: 'ubuntu'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/core/env/ssh/test.coffee'
          'raw.idmap': if process.env['NIKITA_LXD_IN_VAGRANT']
          then 'both 1000 1234'
          else "both #{process.getuid()} 1234"
        disk:
          nikitadir:
            path: '/nikita'
            source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
        ssh: enabled: true
    provision_container: ({config}) ->
      await @lxc.exec
        $header: 'User `source`'
        container: config.container
        command: '''
        if ! id -u 1234 ; then
          useradd -m -s /bin/bash -u 1234 source
        fi
        mkdir -p /home/source/.ssh && chmod 700 /home/source/.ssh
        if [ ! -f /home/source/.ssh/id_rsa ]; then
          ssh-keygen -t rsa -f /home/source/.ssh/id_rsa -N ''
        fi
        chown -R source /home/source/
        '''
        trap: true
      await @lxc.exec
        $header: 'Node.js'
        container: config.container
        command: """
        export HOME=/home/source
        if command -v node ; then exit 42; fi
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
        . ~/.bashrc
        nvm install node
        """
        user: '1234'
        shell: 'bash'
        trap: true
        code_skipped: 42
      await @lxc.exec
        $header: 'User `target`'
        container: config.container
        command: '''
        if ! id -u 1235; then
          useradd -m -s /bin/bash -u 1235 target
        fi
        mkdir -p /home/target/.ssh && chmod 700 /home/target/.ssh
        pubkey=`cat /home/source/.ssh/id_rsa.pub`
        if ! cat /home/target/.ssh/authorized_keys | grep $pubkey; then
          echo $pubkey > /home/target/.ssh/authorized_keys
        fi
        chown -R target /home/target/
        '''
        trap: true
.catch (err) ->
  console.error err
