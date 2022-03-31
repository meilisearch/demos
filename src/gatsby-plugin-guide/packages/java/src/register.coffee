
# Registration of `nikita.java` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  java:
    keystore_add: '@nikitajs/java/src/keystore_add'
    keystore_remove: '@nikitajs/java/src/keystore_remove'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
