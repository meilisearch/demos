
module.exports =
  tags:
    db: true
  db:
    mariadb:
      admin_username: 'root'
      admin_password: 'rootme'
      engine: 'mariadb'
      host: 'mariadb'
      port: 3306
      admin_db: 'root'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
