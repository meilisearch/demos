
# `nikita.fs.mkdir`

Recursively create a directory. The behavior is similar to the Unix command
`mkdir -p`. It supports an alternative syntax where config is simply the path
of the directory to create.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if directory was created or modified.   

## Simple usage

```js
const {$status} = await nikita.fs.mkdir('./some/dir')
console.info(`Directory was created: ${$status}`)
```

## Advanced usage

```js
const {$status} = await nikita.fs.mkdir({
  $ssh: ssh,
  target: './some/dir',
  uid: 'a_user',
  gid: 'a_group'
  mode: 0o0777 // or '777'
})
console.info(`Directory was created: ${$status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.parent ?= {}
      config.parent = {} if config.parent is true

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cwd':
            type: ['boolean', 'string']
            description: '''
            Current working directory for relative paths. A boolean value only
            apply without an SSH connection and default to `process.cwd()`.
            '''
          'exclude':
            instanceof: 'RegExp'
            description: '''
            Exclude directories matching a regular expression. For example, the
            expression `/\${/` on './var/cache/${user}' exclude the directories
            containing a variables and only apply to `./var/cache/`.
            '''
          'gid':
            $ref: 'module://@nikitajs/core/src/actions/fs/chown#/definitions/config/properties/gid'
          'mode':
            $ref: 'module://@nikitajs/core/src/actions/fs/chmod#/definitions/config/properties/mode'
          'parent':
            oneOf: [
              type: 'boolean'
            ,
              type: 'object'
              properties:
                'gid':
                  $ref: 'module://@nikitajs/core/src/actions/fs/mkdir#/definitions/config/properties/gid'
                'mode':
                  $ref: 'module://@nikitajs/core/src/actions/fs/mkdir#/definitions/config/properties/mode'
                'uid':
                  $ref: 'module://@nikitajs/core/src/actions/fs/mkdir#/definitions/config/properties/uid'
            ]
            description: '''
            Create parent directory with provided attributes if an object or
            default system options if "true", supported attributes include 'mode',
            'uid', 'gid', 'size', 'atime', and 'mtime'.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the directory to create.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/src/actions/fs/chown#/definitions/config/properties/uid'
        required: ['target']
        
## Handler

    handler = ({config, tools: {log, path}, ssh}) ->
      # Configuration validation
      config.cwd = process.cwd() if not ssh and (config.cwd is true or not config.cwd)
      config.parent = {} if config.parent is true
      config.target = if config.cwd then path.resolve config.cwd, config.target else path.normalize config.target
      if ssh and not path.isAbsolute config.target
        throw errors.NIKITA_MKDIR_TARGET_RELATIVE config: config
      # Retrieve every directories including parents
      parents = config.target.split path.sep
      parents.shift() # first element is empty with absolute path
      parents.pop() if parents[parents.length - 1] is ''
      parents = for i in [0...parents.length]
        '/' + parents.slice(0, parents.length - i).join '/'
      # Discovery of directories to create
      creates = []
      for target, i in parents
        try
          {stats} = await @fs.base.stat target
          break if utils.stats.isDirectory stats.mode
          throw errors.NIKITA_MKDIR_TARGET_INVALID_TYPE stats: stats, target: target
        catch err
          if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
            creates.push target
          else throw err
      # Target and parent directory creation
      for target, i in creates.reverse()
        if config.exclude? and config.exclude instanceof RegExp
          break if config.exclude.test path.basename target
        opts = {}
        for attr in ['mode', 'uid', 'gid', 'size', 'atime', 'mtime']
          val = if i is creates.length - 1 then config[attr] else config.parent?[attr]
          opts[attr] = val if val?
        await @fs.base.mkdir target, opts
        log message: "Directory \"#{target}\" created ", level: 'INFO'
      # Target directory update
      if creates.length is 0
        log message: "Directory already exists", level: 'DEBUG'
        await @fs.chown
          $if: config.uid? or config.gid?
          target: config.target
          stats: stats
          uid: config.uid
          gid: config.gid
        await @fs.chmod
          $if: config.mode?
          target: config.target
          stats: stats
          mode: config.mode
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'target'
        definitions: definitions

## Errors

    errors =
      NIKITA_MKDIR_TARGET_RELATIVE: ({config}) ->
        utils.error 'NIKITA_MKDIR_TARGET_RELATIVE', [
          'only absolute path are supported over SSH,'
          'target is relative and config `cwd` is not provided,'
          "got #{JSON.stringify config.target}"
        ],
          target: config.target
      NIKITA_MKDIR_TARGET_INVALID_TYPE: ({stats, target}) ->
        utils.error 'NIKITA_MKDIR_TARGET_INVALID_TYPE', [
          'target exists but it is not a directory,'
          "got #{JSON.stringify utils.stats.type stats.mode} type"
          "for #{JSON.stringify target}"
        ],
          target: target

## Dependencies

    utils = require '../../utils'
