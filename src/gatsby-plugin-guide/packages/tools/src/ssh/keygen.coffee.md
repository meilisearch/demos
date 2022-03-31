
# `nikita.ssh.keygen`

Generates keys for use by SSH protocol version 2.

## Example

Force the generation of a key compatible with SSH2. For example in OSX Mojave,
the default export format is RFC4716.

```js
const {$status} = await nikita.tools.ssh.keygen({
  bits: 2048,
  comment: 'my@email.com',
  target: './id_rsa',
  key_format: 'PEM'
})
console.info(`Key was generated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'bits':
            type: 'number'
            default: 4096
            description: '''
            Specifies the number of bits in the key to create.
            '''
          'comment':
            type: 'string'
            description: '''
            Comment such as a name or email.
            '''
          'key_format':
            type: 'string'
            description: '''
            Specify a key format. The supported key formats are: `RFC4716` (RFC
            4716/SSH2 public or private key), `PKCS8` (PEM PKCS8 public key) or
            `PEM` (PEM public key).
            '''
          'passphrase':
            type: 'string'
            default: ''
            description: '''
            Key passphrase, empty string for no passphrase.
            '''
          'target':
            type: 'string'
            description: '''
            Path of the generated private key.
            '''
          'type':
            type: 'string'
            default: 'rsa'
            description: '''
            Type of key to create.
            '''
        required: ['target']

## Handler

    handler = ({config, tools: {path}}) ->
      throw Error "Invalid Option: key_format must be one of RFC4716, PKCS8 or PEM, got #{JSON.stringify config.key_format}" if config.key_format and config.key_format not in ['RFC4716', 'PKCS8', 'PEM']
      await @fs.mkdir
        target: "#{path.dirname config.target}"
      await @execute
        $unless_exists: "#{config.target}"
        command: [
          'ssh-keygen'
          "-q" # Silence
          "-t #{config.type}"
          "-b #{config.bits}"
          "-m #{config.key_format}" if config.key_format
          "-C '#{config.comment.replace '\'', '\\\''}'" if config.comment
          "-N '#{config.passphrase.replace '\'', '\\\''}'"
          "-f #{config.target}"
        ].join ' '

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
