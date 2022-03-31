
# `nikita.system.info.os`

Expose system information. Internally, it uses the command `uname` to retrieve
information.

## Todo

There are more properties exposed by `uname` such as the machine hardware name
and the hardware platform. Those properties shall be exposed.

We shall explain what "non-portable" means.

## Example

```js
const {os} = await nikita.system.info.os()
console.info('Architecture:', os.arch)
console.info('Distribution:', os.distribution)
console.info('Version:', os.version)
console.info('Linux version:', os.linux_version)
```

## Schema definitions

There is no config for this action.

    definitions =
      'output':
        type: 'object'
        properties:
          'os':
            type: 'object'
            properties:
              'arch':
                type: 'string'
                description: '''
                Print the machine architecte, eg `x86_64`, same as `uname -m`.
                '''
              'distribution':
                type: 'string'
                description: '''
                Linux distribution. Current values include 'rhel', 'centos',
                'ubuntu', 'debian' and 'arch'.
                '''
              'version':
                type: 'string'
                description: '''
                Version of the distribution, for example '6.10' on CENTOS 6 or
                `7.9.2009` on CENTOS 7.
                '''
              'linux_version':
                type: 'string'
                description: '''
                Linux kernel version, extracted from `uname -r`.
                '''

## Handler

    handler = ->
      # Using `utils.os.command` to be consistant with OS conditions from core
      {stdout} = await @execute utils.os.command
      [arch, distribution, version, linux_version] = stdout.split '|'
      os:
        arch: arch
        distribution: distribution
        version: if version.length then version else undefined # eg Arch Linux
        linux_version: linux_version

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true

## Dependencies

    utils = require '../utils'
