
path = require 'path'
runner = require '@nikitajs/lxd-runner'

# Note:

# Jan 20th, 2020: upgrading ubuntu to 19.10 on the host vm
# lead to an error while installing freeipa
# complaining that it cannot write into /tmp
# solution involve to run on the host machine
# check: `cat /proc/sys/fs/protected_regular`
# Temporary: `echo '0' > /proc/sys/fs/protected_regular && sysctl -p`
# Permanently: `echo 'fs.protected_regular = 0' >> /etc/sysctl.conf && sysctl -p`

# Error starting IPA
# command:
#    ipactl start
#    Starting Directory Service
#    Failed to start Directory Service: Command '/bin/systemctl start dirsrv@NIKITA-LOCAL.service' returned non-zero exit status 1
# Solution:
# Check available space on host machine

# When adding principal, got Error
# Host 'ipa.nikita.local' does not have corresponding DNS A/AAAA record
# Short term solution:
# Reset the DNS server in resolv.conf with the IPA DNS
#     echo 'search nikita.local' > /etc/resolv.conf
#     echo 'nameserver 10.10.11.2' >> /etc/resolv.conf
#     ipactl restart
# Long term solution:
# Disable the re-generation of resolv.conf by /usr/sbin/dhclient-script

runner
  cwd: '/nikita/packages/ipa'
  container: 'nikita-ipa'
  logdir: path.resolve __dirname, './logs'
  cluster:
    # FreeIPA do a reverse lookup on initialisation
    # Using the default bridge yields to the error
    # `The host name freeipa.nikita does not match the value freeipa.lxd obtained by reverse lookup on IP address fd42:f662:97ea:ba7f:216:3eff:fe1d:96f2%215`
    networks:
      nktipapub:
        'ipv4.address': '10.10.11.1/24'
        'ipv4.nat': true
        'ipv6.address': 'none'
        'dns.domain': 'nikita.local'
    containers:
      'nikita-ipa':
        image: 'images:centos/7'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/ipa/env/ipa/test.coffee'
          'raw.idmap': if process.env['NIKITA_LXD_IN_VAGRANT']
          then 'both 1000 0'
          else "both #{process.getuid()} 0"
        disk:
          nikitadir:
            path: '/nikita'
            source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
        nic:
          eth0:
            name: 'eth0', nictype: 'bridged', parent: 'nktipapub'
            'ipv4.address': '10.10.11.2'
        proxy:
          ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
          ipa_ui_http: listen: 'tcp:0.0.0.0:2080', connect: 'tcp:127.0.0.1:80'
          ipa_ui_https: listen: 'tcp:0.0.0.0:2443', connect: 'tcp:127.0.0.1:443'
        ssh: enabled: true
    provision_container: ({config}) ->
      await @lxc.exec
        $header: 'Node.js'
        code_skipped: 42
        command: '''
        bash -l -c "command -v node" && exit 42
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
        . ~/.bashrc
        nvm install node
        '''
        container: config.container
        trap: true
      await @lxc.exec
        $header: 'SSH keys'
        code_skipped: 42
        command: """
        grep "`cat /root/.ssh/id_rsa.pub`" /root/.ssh/authorized_keys && exit 42
        mkdir -p /root/.ssh && chmod 700 /root/.ssh
        if [ ! -f /root/.ssh/id_rsa ]; then
          ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
          cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
        fi
        """
        container: config.container
        trap: true
      await @lxc.exec
        $header: 'Install FreeIPA'
        code_skipped: 42
        # Other possibilities to check ipa status:
        # echo > /dev/tcp/localhost/443
        # echo admin_pw | kinit admin
        command: """
        [ -f /etc/ipa/default.conf ] && exit 42
        yum install -y freeipa-server ipa-server-dns
        hostnamectl set-hostname ipa.nikita.local --static
        #{[
          'ipa-server-install', '-U'
          #  Basic options
          "-a admin_pw"
          "-p manager_pw"
          # The container is named `nikita-ipa` and it is attached to a network
          # with the `nikita.local` DNS domain. Thus, the default FQDN is
          # `nikita-ipa.nikita.local` and you can do a reverse DNS lookup with
          # `dig -x`.
          "--hostname ipa.nikita.local"
          "--domain nikita.local"
          # We can set a different FQDN like `ipa.nikita.local` with `hostnamectl
          # set-hostname {fqdn} --static`. However, FreeIPA will complain when it
          # starts because the reverse DNS lookup check fail to match the FQDN. A
          # possible solution is to have FreeIPA managing the DNS with
          # `--setup-dns`.
          "--setup-dns --auto-reverse --auto-forwarders"
          # Kerberos REALM
          "-r NIKITA.LOCAL"
        ].join ' '}
        """
        container: config.container
        # ipa-server-install --uninstall
        # ipa-server-install -U -a admin_pw -p manager_pw --hostname ipa.nikita.local --domain nikita.local --auto-reverse --setup-dns --auto-forwarders -r NIKITA.LOCAL
      await @lxc.exec
        $header: 'Immutable DNS'
        code_skipped: 42
        command: '''
        cat /etc/sysconfig/network-scripts/ifcfg-eth0 | egrep '^PEERDNS=no' && exit 42
        echo 'PEERDNS=no' >> /etc/sysconfig/network-scripts/ifcfg-eth0
        '''
        container: config.container
        trap: true
.catch (err) ->
  console.error err
