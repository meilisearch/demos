
module.exports =
  tags:
    system_info_disks: true
    system_info_os: true
  expect:
    os:
      arch: 'x86_64'
      distribution: 'arch'
      linux_version: /\d+\.\d+\.\d+/
      version: undefined
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
