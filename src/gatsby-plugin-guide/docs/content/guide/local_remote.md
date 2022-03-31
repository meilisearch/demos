---
navtitle: Local and Remote (SSH)
sort: 4
---

# Local and remote (SSH) execution

Nikita is designed to run transparently either locally or remotely through SSH. The tests are themselves written to run in both modes.

The `ssh` configuration property must be provided for the action to run remotely. This property may either be an existing SSH connection object or a configuration object.

## Implementation

Behind the scene, the [ssh2] package written by [Brian White](https://github.com/mscdex) is used to assure SSH transport. This is a pure JavaScript package written for Node.js.

To create a connection, we use [ssh2-connect]. The package simplifies the creation of a connection and also provides a few additional configurations.

## Configurations

If the `ssh` property is a configuration object, the configuration used to initialize the SSH connection is the one of the [ssh2] package as well as the one of the [ssh2-connect] package.

> Note, the [ssh2-connect] package will automatically convert the properties from snake case to camel case.

The [ssh2] configuration properties:
  
* `host` (string)   
  Hostname or IP address of the remote server. Default is `127.0.0.1`.

* `port` (integer)   
  Port of the remote server. Default is `22`.

* `hostHash` (string)   
  `md5` or `sha1`. The host's key is hashed using this method and passed to the hostVerifier function. Default: `(none)`

* `hostVerifier` (function)   
  Function that is passed a string hex hash of the host's key for verification purposes. Return true to continue with the connection, false to reject and disconnect. Default: (none)

* `username` (string)   
  Username for authentication. Default: (none)

* `password` (string)   
  The password of the user used to authenticate and create the SSH connection.

* `agent` (string)   
  Path to ssh-agent's UNIX socket for ssh-agent-based user authentication. Windows users: set to 'pageant' for authenticating with Pageant or (actual) path to Cygwin "UNIX socket.". Default: (none)

* `privateKey` (mixed)   
  Content of the private key used to authenticate the user and create the SSH connection. It is only used if `password` is not provided.

* `passphrase` (string)   
  For an encrypted private key, this is the passphrase used to decrypt it. Default: (none)

* `tryKeyboard` (boolean)   
  Try keyboard-interactive user authentication if the primary user authentication method fails. Default: `false`

* `pingInterval` (integer)   
  How often (in milliseconds) to send SSH-level keepalive packets to the server. Default: `60000`

* `readyTimeout` (integer)   
  How long (in milliseconds) to wait for the SSH handshake to complete. Default: `10000`

* `sock` (ReadableStream)   
  A ReadableStream to use for communicating with the server instead of creating and using a new TCP connection (useful for connection hopping).

* `agentForward` (boolean)   
  Set to true to use OpenSSH agent forwarding ('auth-agent@openssh.com'). Default: `false`

The [ssh2-connect] configuration properties:

- `username` (string)   
  Username of the user used to authenticate and create the SSH connection. Default is `root`.

- `privateKeyPath` (string)   
  Local file location of the private key used to authenticate the user and create the SSH connection. It is only used if `password` and `private_key` are not provided. Default is `~/.sh/id_rsa`.   

- `retry` (integer)   
  Attempt to reconnect multiple times. Default is `1`.   

- `wait` (integer)   
  Time to wait in milliseconds between each retry. Default is `500`.  

Additional configuration properties:

- `ip` (string)   
  IP address of the remote server, used if `host` option isn't already defined.
  
- `root` (object)   
  Configuration passed to `nikita.ssh.root` to enable password-less root login.

- `ssh` (object)   
  Associate an existing SSH connection to the current action and its siblings.

## Examples

### Passing an existing SSH connection

```js
const connect = require('ssh2-connect');
// Create an SSH connection
connect({
  host: 'localhost',
  username: 'root',
  privateKeyPath: '~/.ssh/id_rsa'
}, async function(err, ssh){
  if(err) return process.exit(1)
  // Pass the connection to the `file.touch` action
  const {$status} = await nikita.file.touch({
    $ssh: ssh,
    target: '/tmp/nikita/a_file'
  })
  console.info('File is written: ' + $status)
  ssh.end()
})
```

### Passing an SSH configuration

```js
(async () => {
  const {$status} = await nikita
  .file.touch({
    $ssh: {
      host: 'localhost',
      username: 'root',
      private_key_path: '~/.ssh/id_rsa'
    },
    target: '/tmp/nikita/a_file'
  })
  console.info('File is written: ' + $status);
})()
```

## Root access

If root privileges are required and root access is not available because no authorized key has been set, it is possible to let Nikita deploy the public key or execute Nikita with [`sudo`](/current/api/metadata/sudo/).

The `root` option instructs the `ssh.open` action to enable root access through another user. This user must have passwordless sudo enabled.

```js
nikita
// Open SSH
.ssh.open({
  host: 'localhost',
  username: 'root',
  // The private key of the targeted user
  private_key_path: './root_id_rsa',
  root: {
    username: 'vagrant',
    // The private key of the sudo user used to bootstrap the connection
    private_key_path: require('os').homedir()+'/.vagrant.d/insecure_private_key',
    // The public key to deploy
    public_key_path: 'root_id_rsa.pub'
  }
})
// Touch file remotely
.file.touch({
  target: '/tmp/nikita/a_file'
})
// Close SSH
.ssh.close()
```

To enable `sudo`, just enable sudo as a global property or for any action. The property will be propagated to its children and siblings.

```js
const assert = require('assert');
// Global sudo activation
nikita({
  sudo: true
})
// Open SSH
.ssh.open({
  host: 'localhost',
  username: process.env['USER'],
  private_key_path: '~/.ssh/id_rsa'
})
// Call remotely
.call(async function(action) {
  const {stdout} = await this.execute({
    command: 'whoami',
    trim: true
  })
  // Running with sudo returns 'root'
  assert.equal(stdout, 'root')
})
// Close SSH
.ssh.close()
```

[ssh2-connect]: https://github.com/wdavidw/ssh2-connect
[ssh2]: https://github.com/mscdex/ssh2
