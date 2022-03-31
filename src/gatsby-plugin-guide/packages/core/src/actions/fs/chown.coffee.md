
# `nikita.fs.chown`

Change the ownership of a file or a directory.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file ownership was created or modified.   

## Example

```js
const {$status} = await nikita.fs.chown({
  target: '~/my/project',
  uid: 'my_user',
  gid: 'my_group'
})
console.info(`Ownership was modified: ${$status}`)
```

## Note

To list all files owner by a user or a uid, run:

```bash
find /var/tmp -user `whoami`
find /var/tmp -uid 1000
find / -uid $old_uid -print | xargs chown $new_uid:$new_gid
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chown#/definitions/config/properties/gid'
          'stats':
            typeof: 'object'
            description: '''
            Stat object of the target file. Short-circuit to avoid fetching the
            stat object associated with the target if one is already available.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the file which permissions will change.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chown#/definitions/config/properties/uid'
        required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      throw Error "Missing one of uid or gid option" unless config.uid? or config.gid?
      if config.uid?
        uid = if typeof config.uid is 'number' then config.uid
        else
          {stdout} = await @execute "id -u '#{config.uid}'"
          parseInt stdout.trim()
      if config.gid?
        gid = if typeof config.gid is 'number' then config.gid
        else
          {stdout} = await @execute "id -g '#{config.gid}'"
          parseInt stdout.trim()
      # Retrieve target stats
      if config.stats
        log message: "Stat short-circuit", level: 'DEBUG'
        stats = config.stats
      else {stats} = await @fs.base.stat config.target
      # Detect changes
      changes =
        uid: uid? and stats.uid isnt uid
        gid: gid? and stats.gid isnt gid
      if not changes.uid and not changes.gid
        log message: "Matching ownerships on '#{config.target}'", level: 'INFO'
        return false
      # Apply changes
      await @fs.base.chown target: config.target, uid: uid, gid: gid
      log message: "change uid from #{stats.uid} to #{uid}", level: 'WARN' if changes.uid
      log message: "change gid from #{stats.gid} to #{gid}", level: 'WARN' if changes.gid
      true

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        definitions: definitions
