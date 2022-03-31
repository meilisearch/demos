
# Registration of `nikita.system` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  system:
    authconfig: '@nikitajs/system/src/authconfig'
    cgroups: '@nikitajs/system/src/cgroups'
    group:
      '': '@nikitajs/system/src/group'
      read: '@nikitajs/system/src/group/read'
      remove: '@nikitajs/system/src/group/remove'
    info:
      disks: '@nikitajs/system/src/info/disks'
      os: '@nikitajs/system/src/info/os'
    limits: '@nikitajs/system/src/limits'
    mod: '@nikitajs/system/src/mod'
    running: '@nikitajs/system/src/running'
    tmpfs: '@nikitajs/system/src/tmpfs'
    uid_gid: '@nikitajs/system/src/uid_gid'
    user:
      '': '@nikitajs/system/src/user'
      read: '@nikitajs/system/src/user/read'
      remove: '@nikitajs/system/src/user/remove'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
