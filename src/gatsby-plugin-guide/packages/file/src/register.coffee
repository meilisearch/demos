
# Registration of `nikita.file` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  file:
    '': '@nikitajs/file/src'
    cache: '@nikitajs/file/src/cache'
    cson: '@nikitajs/file/src/cson'
    download: '@nikitajs/file/src/download'
    ini: '@nikitajs/file/src/ini'
    json: '@nikitajs/file/src/json'
    properties:
      '': '@nikitajs/file/src/properties'
      read: '@nikitajs/file/src/properties/read'
    render: '@nikitajs/file/src/render'
    touch: '@nikitajs/file/src/touch'
    types:
      'systemd':
        'resolved': '@nikitajs/file/src/types/systemd/resolved'
        'timesyncd': '@nikitajs/file/src/types/systemd/timesyncd'
      'ceph_conf': '@nikitajs/file/src/types/ceph_conf'
      'hfile': '@nikitajs/file/src/types/hfile'
      'krb5_conf': '@nikitajs/file/src/types/krb5_conf'
      'locale_gen': '@nikitajs/file/src/types/locale_gen'
      'my_cnf': '@nikitajs/file/src/types/my_cnf'
      'pacman_conf': '@nikitajs/file/src/types/pacman_conf'
      'ssh_authorized_keys': '@nikitajs/file/src/types/ssh_authorized_keys'
      'wireguard_conf': '@nikitajs/file/src/types/wireguard_conf'
      'yum_repo': '@nikitajs/file/src/types/yum_repo'
    upload: '@nikitajs/file/src/upload'
    yaml: '@nikitajs/file/src/yaml'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
