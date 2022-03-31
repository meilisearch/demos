
{merge} = require 'mixme'
utils = require '../utils'
session = require '../session'

###
Pass an SSH connection or SSH information to an action. Disable SSH if the value
is `null` or `false`.
###

module.exports =
  name: '@nikitajs/core/src/plugins/ssh'
  require: [
    '@nikitajs/core/src/plugins/tools/find'
  ]
  hooks:
    # 'nikita:normalize': (action, handler) ->
    #   # Dont interfere with ssh actions
    #   return handler if action.metadata.namespace[0] is 'ssh'
    #   if action.hasOwnProperty 'ssh'
    #     ssh = action.ssh
    #     delete action.ssh
    #   ->
    #     action = await handler.call null, ...arguments
    #     action.ssh = ssh
    #     action
    'nikita:action': (action) ->
      # Is there a connection to open
      if action.ssh and not utils.ssh.is action.ssh
        {ssh} = await session.with_options [{}],
          plugins: [ # Need to inject `tools.log`
            require './tools/events'
            require './tools/log'
            require './output/status'
            require './history'
          ]
        .ssh.open action.ssh
        action.metadata.ssh_dispose = true
        action.ssh = ssh
        return
      # Find SSH connection in parent actions
      ssh = await action.tools.find (action) ->
        action.ssh
      if ssh
        throw utils.error 'NIKITA_SSH_INVALID_STATE', [
          'the `ssh` property is not a connection',
          "got #{JSON.stringify ssh}"
        ] unless utils.ssh.is ssh
        action.ssh = ssh
        return
      else if ssh is null or ssh is false
        action.ssh = null unless action.ssh is undefined
        return
      else unless ssh is undefined
        throw utils.error 'NIKITA_SSH_INVALID_VALUE', [
          'when disabled, the `ssh` property must be `null` or `false`,'
          'when enable, the `ssh` property must be a connection or a configuration object',
          "got #{JSON.stringify ssh}"
        ]
      # Find SSH open in previous siblings
      for sibling in action.siblings
        continue unless sibling.metadata.module is '@nikitajs/core/src/actions/ssh/open'
        if sibling.output.ssh
          ssh = sibling.output.ssh
          break
      # Then only set the connection if still open
      if ssh and (ssh._sshstream?.writable or ssh._sock?.writable)
        action.ssh = ssh
    'nikita:result': ({action}) ->
      if action.metadata.ssh_dispose
        await session.with_options [{}],
          plugins: [ # Need to inject `tools.log`
            require './tools/events'
            require './tools/log'
            require './output/status'
            require './history'
          ]
        .ssh.close ssh: action.ssh
