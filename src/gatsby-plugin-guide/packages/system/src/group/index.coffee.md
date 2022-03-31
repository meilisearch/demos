
# `nikita.system.group`

Create or modify a Unix group.

## Callback Parameters
 
* `$status`   
  Value is "true" if group was created or modified.   

## Example

```js
const {$status} = await nikita.system.group({
  name: 'myself'
  system: true
  gid: 490
});
console.log(`Group was created/modified: ${$status}`);
```

The result of the above action can be viewed with the command
`cat /etc/group | grep myself` producing an output similar to
"myself:x:490:".

## Hooks

    on_action = ({config}) ->
      config.gid = parseInt config.gid, 10 if typeof config.gid is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            type: 'integer'
            description: '''
            Group name or number of the user´s initial login group.
            '''
          'name':
            type: 'string'
            description: '''
            Login name of the group.
            '''
          'system':
            type: 'boolean'
            default: false
            description: '''
            Create a system account, such user are not created with ahome by
            default, set the "home" option if we it to be created.
            '''
        required: ['name']

## Handler

    handler = ({config, tools: {log}}) ->
      config.system ?= false
      config.gid ?= null
      # throw Error 'Invalid gid option' if config.gid? and isNaN config.gid
      {groups} = await @system.group.read()
      info = groups[config.name]
      log if info
      then message: "Got group information for #{JSON.stringify config.name}", level: 'DEBUG', module: 'nikita/lib/system/group'
      else message: "Group #{JSON.stringify config.name} not present", level: 'DEBUG', module: 'nikita/lib/system/group'
      unless info # Create group
        {$status} = await @execute
          command: [
            'groupadd'
            '-r' if config.system
            "-g #{config.gid}" if config.gid?
            config.name
          ].join ' '
          code_skipped: 9
        log message: "Group defined elsewhere than '/etc/group', exit code is 9", level: 'WARN' unless $status
      else # Modify group
        changes = ['gid'].filter (k) -> config[k]? and "#{info[k]}" isnt "#{config[k]}"
        if changes.length
          await @execute
            command: [
              'groupmod'
              " -g #{config.gid}" if config.gid
              config.name
            ].join ' '
          log message: "Group information modified", level: 'WARN'
        else
          log message: "Group information unchanged", level: 'INFO'

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'name'
        definitions: definitions
