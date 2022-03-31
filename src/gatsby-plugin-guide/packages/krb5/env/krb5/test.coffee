
module.exports =
  tags:
    krb5: true
    krb5_addprinc: true
    krb5_delprinc: true
    krb5_ktadd: true
  krb5:
    realm: 'NODE.DC1.CONSUL'
    server: 'krb5'
    principal: 'admin/admin@NODE.DC1.CONSUL'
    password: 'admin'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
