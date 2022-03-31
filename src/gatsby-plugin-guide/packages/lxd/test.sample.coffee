
module.exports =
  tags:
    lxd: true
    lxd_vm: process.platform is 'linux'
    lxd_prlimit: true
  images:
    alpine: 'alpine/3.13'
  config: [
    label: 'local'
    # label: 'remote'
    # ssh:
    #   host: '127.0.0.1', username: process.env.USER,
    #   private_key_path: '~/.ssh/id_rsa'
    # Exemple with vagrant:
    # ssh:
    #   host: '127.0.0.1', port: 2222, username: 'vagrant'
    #   private_key_path: "#{require('os').homedir()}/.vagrant.d/insecure_private_key"
  ]
