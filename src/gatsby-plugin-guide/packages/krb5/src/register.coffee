
# Registration of `nikita.krb5` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  krb5:
    addprinc: '@nikitajs/krb5/src/addprinc'
    delprinc: '@nikitajs/krb5/src/delprinc'
    execute: '@nikitajs/krb5/src/execute'
    ktadd: '@nikitajs/krb5/src/ktadd'
    ticket: '@nikitajs/krb5/src/ticket'
    ktutil:
      add: '@nikitajs/krb5/src/ktutil/add'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
