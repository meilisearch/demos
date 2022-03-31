
module.exports =
  tags:
    tools_dconf: true
  config: [
    label: 'local'
    env: DBUS_SESSION_BUS_ADDRESS:'unix:path=/tmp/dbus.sock'
  ,
    label: 'remote'
    env: DBUS_SESSION_BUS_ADDRESS:'unix:path=/tmp/dbus.sock'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
