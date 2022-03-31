
# Registration of `nikita.network` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  network:
    http:
      '': '@nikitajs/network/src/http'
    tcp:
      'assert': '@nikitajs/network/src/tcp/assert'
      'wait': '@nikitajs/network/src/tcp/wait'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
