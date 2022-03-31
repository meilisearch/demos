
module.exports =
  tags:
    ipa: true
  ipa:
    principal: 'admin'
    password: 'admin_pw'
    # referer: 'https://freeipa.nikita.local/ipa/xml'
    url: 'https://ipa.nikita.local/ipa/session/json'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
