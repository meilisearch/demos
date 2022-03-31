
module.exports =
  tags:
    api: true
    ldap: false
    ldap_acl: false
    ldap_index: false
    ldap_user: false
  ldap:
    uri: 'ldap://localhost:389'
    binddn: 'cn=admin,dc=example,dc=org'
    passwd: 'admin'
    config:
      binddn: 'cn=admin,cn=config'
      passwd: 'config'
    suffix_dn: 'dc=example,dc=org'
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
