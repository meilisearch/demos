
# Registration of `nikita.log` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  log:
    cli: '@nikitajs/log/src/cli'
    csv: '@nikitajs/log/src/csv'
    fs: '@nikitajs/log/src/fs'
    md: '@nikitajs/log/src/md'
    stream: '@nikitajs/log/src/stream'
    
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
