
module.exports =
  tags:
    db: true
  db:
    postgresql:
      admin_username: 'root'
      admin_password: 'rootme'
      engine: 'postgresql'
      host: 'postgres'
      port: 5432
      admin_db: 'root'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
