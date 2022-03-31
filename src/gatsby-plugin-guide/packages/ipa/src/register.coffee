
# Registration of `nikita.ipa` actions

require '@nikitajs/network/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  ipa:
    group:
      '': '@nikitajs/ipa/src/group'
      add_member: '@nikitajs/ipa/src/group/add_member'
      del: '@nikitajs/ipa/src/group/del'
      exists: '@nikitajs/ipa/src/group/exists'
      show: '@nikitajs/ipa/src/group/show'
    user:
      '': '@nikitajs/ipa/src/user'
      disable: '@nikitajs/ipa/src/user/disable'
      del: '@nikitajs/ipa/src/user/del'
      enable: '@nikitajs/ipa/src/user/enable'
      exists: '@nikitajs/ipa/src/user/exists'
      find: '@nikitajs/ipa/src/user/find'
      show: '@nikitajs/ipa/src/user/show'
      status: '@nikitajs/ipa/src/user/status'
    service:
      '': '@nikitajs/ipa/src/service'
      del: '@nikitajs/ipa/src/service/del'
      exists: '@nikitajs/ipa/src/service/exists'
      show: '@nikitajs/ipa/src/service/show'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
