
# Registration of `nikita.ldap` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  ldap:
    acl: '@nikitajs/ldap/src/acl'
    add: '@nikitajs/ldap/src/add'
    delete: '@nikitajs/ldap/src/delete'
    index: '@nikitajs/ldap/src/index'
    modify: '@nikitajs/ldap/src/modify'
    schema: '@nikitajs/ldap/src/schema'
    search: '@nikitajs/ldap/src/search'
    tools:
      database: '@nikitajs/ldap/src/tools/database'
      databases: '@nikitajs/ldap/src/tools/databases'
    user: '@nikitajs/ldap/src/user'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
