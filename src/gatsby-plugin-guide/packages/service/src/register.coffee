
# Registration of `nikita.service` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  service:
    '': '@nikitajs/service/src'
    assert: '@nikitajs/service/src/assert'
    discover: '@nikitajs/service/src/discover'
    install: '@nikitajs/service/src/install'
    init: '@nikitajs/service/src/init'
    remove: '@nikitajs/service/src/remove'
    restart: '@nikitajs/service/src/restart'
    start: '@nikitajs/service/src/start'
    startup: '@nikitajs/service/src/startup'
    status: '@nikitajs/service/src/status'
    stop: '@nikitajs/service/src/stop'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
