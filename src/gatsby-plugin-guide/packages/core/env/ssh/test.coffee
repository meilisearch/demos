
module.exports =
  tags:
    ssh: true
  config: [
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: 'target',
      private_key_path: '~/.ssh/id_rsa'
  ]
