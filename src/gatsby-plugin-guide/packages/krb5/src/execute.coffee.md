
# `nikita.krb5.execute`

Execute a Kerberos command.

## Example

```js
const {$status} = await nikita.krb5.exec({
  command: 'listprincs'
})
console.info(`Command was executed: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      throw Error 'Deprecated config `egrep`' if config.egrep?

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin':
            type: 'object'
            properties:
              'realm':
                type: 'string'
                description: '''
                The realm the principal belongs to.
                '''
              'principal':
                type: 'string'
                description: '''
                KAdmin principal name unless `kadmin.local` is used.
                '''
              'server':
                type: 'string'
                description: '''
                Address of the kadmin server; optional, use "kadmin.local" if
                missing.
                '''
              'password':
                type: 'string'
                description: '''
                Password associated to the KAdmin principal.
                '''
          'command':
            type: 'string'
            description: '''
            '''
          'grep':
            oneOf: [
              {type: 'string'}
              {instanceof: 'RegExp'}
            ]
            description: '''
            Ensure the execute output match a string or a regular expression.
            '''
        required: ['admin', 'command']

## Handler

    handler = ({config}) ->
      realm = if config.admin.realm then "-r #{config.admin.realm}" else ''
      {stdout} = await @execute
        command: if config.admin.principal
        then "kadmin #{realm} -p #{config.admin.principal} -s #{config.admin.server} -w #{config.admin.password} -q '#{config.command}'"
        else "kadmin.local #{realm} -q '#{config.command}'"
      if config.grep and typeof config.grep is 'string'
        return stdout: stdout, $status: stdout.split('\n').some (line) -> line is config.grep
      if config.grep and utils.regexp.is config.grep
        return stdout: stdout, $status: stdout.split('\n').some (line) -> config.grep.test line
      $status: true, stdout: stdout

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'krb5'
        definitions: definitions

## Dependencies

    {mutate} = require 'mixme'
    utils = require '@nikitajs/core/lib/utils'
