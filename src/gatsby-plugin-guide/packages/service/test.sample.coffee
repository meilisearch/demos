
module.exports =
  tags:
    api: true
    service_install: false
    service_systemctl: false
    service_startup: false
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
    # Exemple with vagrant:
    # ssh:
    #   host: '127.0.0.1', port: 2222, username: 'vagrant'
    #   private_key_path: "#{require('os').homedir()}/.vagrant.d/insecure_private_key"
  ]
