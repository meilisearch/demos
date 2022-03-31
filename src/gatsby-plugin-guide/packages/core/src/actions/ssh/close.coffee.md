
# `nikita.ssh.close`

Close the existing connection if any.

## Configuration

* `ssh` (boolean)   
  Return the SSH connection if any and if true, null if false.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'ssh':
            instanceof: 'Object'
            description: '''
            The SSH connection to close, default to currently active SSH
            connection avaible to the action.
            '''

## Handler

    handler = ({config, siblings}) ->
      config.ssh ?= siblings
        .map( ({output}) -> output?.ssh )
        .find (ssh) -> !!ssh
      throw utils.error 'NIKITA_SSH_CLOSE_NO_CONN', [
        'There is no connection to close,'
        'either pass the connection in the `ssh` configuation'
        'or ensure a connection was open in a sibling action'
      ] unless config.ssh
      # Exit if the connection is already close
      return false unless config.ssh._sshstream?.writable and config.ssh._sock?.writable
      # Terminate the connection
      new Promise (resolve, reject) ->
        config.ssh.end()
        config.ssh.on 'error', reject
        config.ssh.on 'end', ->
          resolve true

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        
## Dependencies

    utils = require '../../utils'
