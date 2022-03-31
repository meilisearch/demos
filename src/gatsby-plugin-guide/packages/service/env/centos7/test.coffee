
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false # cant be activated because systemctl not compatible with Docker
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
