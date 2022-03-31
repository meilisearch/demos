
module.exports =
  tags:
    conditions_if_os: true
  conditions_if_os:
    # arch: 'x86_64'
    # https://en.wikipedia.org/wiki/Uname#Examples
    # Note, on Apple M1, inside the container:
    # `node -e 'console.info(os.arch())'` print `arm64`
    # `uname -m` print `aarch64`
    arch: ['x86_64', 'arm64', 'aarch64']
    distribution: 'ubuntu'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/lsb-release` to check the Ubuntu version
    version: '14.04'
    linux_version: '5.10'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
