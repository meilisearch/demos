
# Registration of `nikita.tools` actions

require '@nikitajs/file/lib/register'
require '@nikitajs/service/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  tools:
    apm:
      '': '@nikitajs/tools/src/apm'
      'installed': '@nikitajs/tools/src/apm/installed'
      'uninstall': '@nikitajs/tools/src/apm/uninstall'
    backup: '@nikitajs/tools/src/backup'
    compress: '@nikitajs/tools/src/compress'
    cron:
      add: '@nikitajs/tools/src/cron/add'
      remove: '@nikitajs/tools/src/cron/remove'
    extract: '@nikitajs/tools/src/extract'
    dconf: '@nikitajs/tools/src/dconf'
    iptables: '@nikitajs/tools/src/iptables'
    git: '@nikitajs/tools/src/git'
    npm:
      '': '@nikitajs/tools/src/npm'
      list: '@nikitajs/tools/src/npm/list'
      outdated: '@nikitajs/tools/src/npm/outdated'
      uninstall: '@nikitajs/tools/src/npm/uninstall'
      upgrade: '@nikitajs/tools/src/npm/upgrade'
    repo: '@nikitajs/tools/src/repo'
    rubygems:
      'fetch': '@nikitajs/tools/src/rubygems/fetch'
      'install': '@nikitajs/tools/src/rubygems/install'
      'remove': '@nikitajs/tools/src/rubygems/remove'
    ssh:
      keygen: '@nikitajs/tools/src/ssh/keygen'
    sysctl: '@nikitajs/tools/src/sysctl'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
