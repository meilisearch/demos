
module.exports =
  tags:
    api: false
    krb5: false
    krb5_addprinc: false
    krb5_delprinc: false
    krb5_ktadd: false
  krb5:
    realm: 'DOMAIN.COM'
    kadmin_server: 'domain.com'
    kadmin_principal: 'nikita/admin@DOMAIN.COM'
    kadmin_password: 'test'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
    # Exemple with vagrant:
    # ssh:
    #   host: '127.0.0.1', port: 2222, username: 'vagrant'
    #   private_key_path: "#{require('os').homedir()}/.vagrant.d/insecure_private_key"
  ]
