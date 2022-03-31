
# `nikita.java.keystore_remove`

Remove certificates, private keys and certificate authorities from java
keystores and truststores.

## Removing a key and its certificate

```js
const {$status} = await nikita.java.keystore_remove([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate',
  keypass: 'mypassword',
  name: 'node_1'
})
console.info(`Key and its certificate were updated: ${$status}`)
```

## Removing a certificate authority

```js
const {$status} = await nikita.java.keystore_remove([{
  keystore: java_home + '/lib/security/cacerts',
  storepass: 'changeit',
  caname: 'my_ca_certificate'
})
console.info(`Certificate authority was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'name':
            type: 'array'
            items: type: 'string'
            default: []
            description: '''
            Alias of the key and the certificate.
            '''
          'caname':
            type: 'array'
            items: type: 'string'
            default: []
            description: '''
            Alias of the certificate authority (CA).
            '''
          'keytool':
            type: 'boolean'
            description: '''
            Path to the `keytool` command, detetected from `$PATH` by default.
            '''
          'keystore':
            type: 'string'
            description: '''
            Path to the keystore (doesn't need to exists).
            '''
          'storepass':
            type: 'string'
            description: '''
            Password to manage the keystore.
            '''
        required: ['keystore', 'storepass']
        anyOf: [
          {required: ['name']}
          {required: ['caname']}
        ]
      
## Handler

    handler = ({config}) ->
      # config.caname = [config.caname] unless Array.isArray config.caname
      # config.name = [config.name] unless Array.isArray config.name
      aliases = [config.caname..., config.name...].join(' ').trim()
      config.keytool ?= 'keytool'
      await @execute
        bash: true
        command: """
        # Detect keytool command
        keytoolbin=#{config.keytool}
        command -v $keytoolbin >/dev/null || {
          if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
          else exit 7; fi
        }
        test -f "#{config.keystore}" || # Nothing to do if not a file
        exit 3
        count=0
        for alias in #{aliases}; do
          if ${keytoolbin} -list -keystore "#{config.keystore}" -storepass "#{config.storepass}" -alias "$alias"; then
             ${keytoolbin} -delete -keystore "#{config.keystore}" -storepass "#{config.storepass}" -alias "$alias"
             (( count++ ))
          fi
        done
        [ $count -eq 0 ] && exit 3
        exit 0
        """
        code_skipped: 3

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
