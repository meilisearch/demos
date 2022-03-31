
module.exports =
  tags:
    db: true
  db:
    mysql:
      engine: 'mysql'
      host: 'mysql'
      port: 3306
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
