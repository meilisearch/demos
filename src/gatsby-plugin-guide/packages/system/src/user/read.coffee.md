
# `nikita.system.user.read`

Read and parse the passwd definition file located in "/etc/passwd".

## Output parameters

* `users`   
  An object where keys are the usernames and values are the user properties.
  See the parameter `user` for a list of available properties.
* `user`
  Properties associated witht the user, only if the input parameter `uid` is
  provided. Available properties are:   
  * `user` (string)   
  Username.
  * `uid` (integer)   
  User Id.
  * `comment` (string)   
  User description
  * `home` (string)   
  User home directory.
  * `shell` (string)   
  Default user shell command.

## Example

```js
const {$status, users} = await nikita
.file({
  target: "/tmp/etc/passwd",
  content: "root:x:0:0:root:/root:/bin/bash"
})
.system.user.read({
  target: "/tmp/etc/passwd"
})
assert.equal($status, false)
assert.deepEqual(users, {
  "root": { user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash' }
})
```

## Implementation

The default implementation use the `getent passwd` command. It is possible to
read an alternative `/etc/passwd` file by setting the `target` option to the
targeted file.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'target':
            type: 'string'
            description: '''
            Path to the passwd definition file, use the `getent passwd` command by
            default which use to "/etc/passwd".
            '''
          'uid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/uid'
            description: '''
            Retrieve the information for a specific username or uid.
            '''

## Handler

    handler = ({config}) ->
      config.uid = parseInt config.uid, 10 if typeof config.uid is 'string' and /\d+/.test config.uid
      # Parse the passwd output
      str2passwd = (data) ->
        passwd = {}
        for line in utils.string.lines data
          line = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          passwd[line[1]] = user: line[1], uid: parseInt(line[2]), gid: parseInt(line[3]), comment: line[4], home: line[5], shell: line[6]
        passwd
      # Fetch the users information
      unless config.target
        {stdout} = await @execute
          command: 'getent passwd'
        passwd = str2passwd stdout
      else
        {data} = await @fs.base.readFile
          target: config.target
          encoding: 'ascii'
        passwd = str2passwd data
      # Return all the users
      return users: passwd unless config.uid
      # Return a user by username
      if typeof config.uid is 'string'
        user = passwd[config.uid]
        throw Error "Invalid Option: no uid matching #{JSON.stringify config.uid}" unless user
        user: user
      # Return a user by uid
      else
        user = Object.values(passwd).filter((user) -> user.uid is config.uid)[0]
        throw Error "Invalid Option: no uid matching #{JSON.stringify config.uid}" unless user
        user: user

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true

## Dependencies

    utils = require '../utils'
