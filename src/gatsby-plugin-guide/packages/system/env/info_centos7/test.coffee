
module.exports =
  tags:
    system_info_disks: true
    system_info_os: true
  expect:
    os:
      arch: /x86_64|aarch64/
      distribution: 'centos'
      linux_version: /5\.10\.\d+/
      version: /7\.9\.\d+/
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
