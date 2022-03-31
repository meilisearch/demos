
# `nikita.system.group.read`

Read and parse the group definition file located in "/etc/group".

## Output parameters

* `groups`   
  An object where keys are the group names and values are the groups properties.
  See the parameter `group` for a list of available properties.
* `group`
  Properties associated witht the group, only if the input parameter `gid` is
  provided. Available properties are:   
  * `group` (string)   
  Name of the group.
  * `password` (string)   
  Group password as a result of the `crypt` function, rarely used.
  * `gid` (string)   
  The numerical equivalent of the group name. It is used by the operating
  system and applications when determining access privileges.
  * `users` (array[string])   
  List of users who are members of this group.

## Examples

Retrieve all groups informations:

```js
const {groups} = await nikita.system.group.read()
console.info("Available groups:", groups)
```

Retrieve information of an individual group:

```js
const {group} = await nikita.system.group.read({
  gid: 1
})
console.info("The group found:", group)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/gid'
            description: '''
            Retrieve the information for a specific group name or gid.
            '''
          'target':
            type: 'string'
            default: '/etc/group'
            description: '''
            Path to the group definition file, default to "/etc/group".
            '''

## Handler

    handler = ({config, metadata, state, tools: {log}}) ->
      config.gid = parseInt config.gid, 10 if typeof config.gid is 'string' and /\d+/.test config.gid
      # Parse the groups output
      str2groups = (data) ->
        groups = {}
        for line in utils.string.lines data
          line = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          groups[line[1]] = group: line[1], password: line[2], gid: parseInt(line[3]), users: if line[4] then line[4].split ',' else []
        groups
      # Fetch the groups information
      unless config.target
        {stdout} = await @execute
          command: 'getent group'
        groups = str2groups stdout
      else
        {data} = await @fs.base.readFile
          target: config.target
          encoding: 'ascii'
        groups = str2groups data
      # Return all the groups
      return groups: groups unless config.gid
      # Return a group by name
      if typeof config.gid is 'string'
        group = groups[config.gid]
        throw Error "Invalid Option: no gid matching #{JSON.stringify config.gid}" unless group
        group: group
      # Return a group by gid
      else
        group = Object.values(groups).filter((group) -> group.gid is config.gid)[0]
        throw Error "Invalid Option: no gid matching #{JSON.stringify config.gid}" unless group
        group: group

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
