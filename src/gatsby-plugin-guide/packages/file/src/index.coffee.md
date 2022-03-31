
# `nikita.file`

Write a file or a portion of an existing file.

## Output

* `$status`   
  Indicate file modifications.

## Implementation details

Internally, this function uses the "chmod" and "chown" function and, thus,
honor all their options including "mode", "uid" and "gid".

## Diff Lines

Diff can be obtained when the options "diff" is set to true or a function. The
information is provided in two ways:

* when `true`, a formated string written to the "stdout" option.
* when a function, a readable diff and the array returned by the function 
  `diff.diffLines`, see the [diffLines] package for additionnal information.

## More about the `append` option

The `append` option allows more advanced usages. If `append` is `null`, it will
add the value of the "replace" option at the end of the file when no match
is found and when the value is a string.

Using the `append` option conjointly with the `match` and `replace` options gets
even more interesting. If append is a string or a regular expression, it will
place the value of the "replace" option just after the match. Internally, a
string value will be converted to a regular expression. For example the string
"test" will end up converted to the regular expression `/test/mg`.

## Replacing part of a file using from and to markers

```js
const {data} = await nikita
.file({
  content: 'Start\n# from\nlets try to replace that one\n# to\nEnd',
  from: '# from\n',
  to: '# to',
  replace: 'New string\n',
  target: `${scratch}/a_file`
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// Start\n# from\nNew string\n# to\nEnd
```

## Replacing a matched line by a string

```js
const {data} = await nikita
.file({
  content: 'email=david(at)adaltas(dot)com\nusername=root',
  match: /(username)=(.*)/,
  replace: '$1=david (was $2)',
  target: `${scratch}/a_file`
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// email=david(at)adaltas(dot)com\nusername=david (was root)
```

## Replacing part of a file using a regular expression

```js
const {data} = await nikita
.file({
  content: 'Start\nlets try to replace that one\nEnd',
  match: /(.*try) (.*)/,
  replace: ['New string, $1'],
  target: `${scratch}/a_file`
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// Start\nNew string, lets try\nEnd
```

## Replacing with the global and multiple lines options

```js
const {data} = await nikita
.file({
  content: '# Start\n#property=30\nproperty=10\n# End',
  match: /^property=.*$/mg,
  replace: 'property=50',
  target: `${scratch}/a_file`
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// # Start\n#property=30\nproperty=50\n# End
```

## Appending a line after each line containing "property"

```js
const {data} = await nikita
.file({
  content: '# Start\n#property=30\nproperty=10\n# End',
  match: /^.*comment.*$/mg,
  replace: '# comment',
  target: `${scratch}/a_file`,
  append: 'property'
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// # Start\n#property=30\n# comment\nproperty=50\n# comment\n# End
```

## Multiple transformations

```js
const {data} = await nikita
.file({
  content: 'username: me\nemail: my@email\nfriends: you',
  write: [
    {match: /^(username).*$/mg, replace: '$1: you'},
    {match: /^email.*$/mg, replace: ''},
    {match: /^(friends).*$/mg, replace: '$1: me'}
  ],
  target: `${scratch}/a_file`
})
.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// username: you\n\nfriends: me
```

## Hooks

    on_action = ({config}) ->
      # Validate parameters
      # TODO: try to express this in JSON schema
      throw Error 'Missing source or content or replace or write' unless (config.source or config.content?) or config.replace? or config.write?
      throw Error 'Define either source or content' if config.source and config.content?
      if config.content
        if typeof config.content is 'number'
          config.content = "#{config.content}"
        else if Buffer.isBuffer config.content
          config.content = config.content.toString()

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'append':
            oneOf: [
              typeof: 'boolean'
            ,
              typeof: 'string'
            ,
              instanceof: 'RegExp'
            ]
            default: false
            description: '''
            Append the content to the target file. If target does not exist, the
            file will be created.
            '''
          'backup':
            type: ['boolean', 'string']
            description: '''
            Create a backup, append a provided string to the filename extension or
            a timestamp if value is not a string, only apply if the target file
            exists and is modified.
            '''
          'backup_mode':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chmod#/definitions/config/properties/mode'
            description: '''
            Backup file mode (permission and sticky bits), defaults to `0o0400`,
            in the  form of `{mode: 0o0400}` or `{mode: "0400"}`.
            '''
          'content':
            oneOf:[
              type: 'string'
            ,
              typeof: 'function'
            ]
            description: '''
            Text to be written, an alternative to source which reference a file.
            '''
          'context':
            type: 'object'
            description: '''
            Context provided to the template engine.
            '''
          'diff':
            typeof: 'function'
            description: '''
            Print diff information, pass a readable diff and the result of
            [jsdiff.diffLines][diffLines] as arguments if a function, default to
            true.
            '''
          'eof':
            type: ['boolean', 'string']
            description: '''
            Ensure the file ends with this charactere sequence, special values are
            'windows', 'mac', 'unix' and 'unicode' (respectively "\r\n", "\r",
            "\n", "\u2028"), will be auto-detected if "true", default to false or
            "\n" if "true" and not detected.
            '''
          'encoding':
            type: 'string'
            default: 'utf8'
            description: '''
            Encoding of the source and target files.
            '''
          'engine':
            type: 'string'
            default: 'handlebars'
            description: '''
            Template engine being used.
            '''
          'from':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Name of the marker from where the content will be replaced.
            '''
          'gid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/gid'
          'local':
            type: 'boolean'
            default: false
            description: '''
            Treat the source as local instead of remote, only apply with "ssh"
            option.
            '''
          'match':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Replace this marker, default to the replaced string if missing.
            '''
          'mode':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chmod#/definitions/config/properties/mode'
          'place_before':
            oneOf: [
              typeof: 'boolean'
            ,
              typeof: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Place the content before the match.
            '''
          'remove_empty_lines':
            type: 'boolean'
            description: '''
            Remove empty lines from content
            '''
          'replace':
            type: ['array', 'string']
            items: type: 'string'
            description: '''
            The content to be inserted, used conjointly with the from, to or match
            options.
            '''
          'source':
            type: 'string'
            description: '''
            File path from where to extract the content, do not use conjointly
            with content.
            '''
          'target':
            oneOf: [
              type: 'string'
            ,
              typeof: 'function'
            ]
            description: '''
            File path where to write content to. Pass the content.
            '''
          'to':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Name of the marker until where the content will be replaced.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/uid'
          'unlink':
            type: 'boolean'
            default: false
            description: '''
            Replace the existing link, leaving the refered file untouched.
            '''
          'write':
            description: '''
            An array containing multiple transformation where a transformation is
            an object accepting the options `from`, `to`, `match` and `replace`.
            '''
            type: 'array'
            items:
              type: 'object'
              properties:
                'from':
                  oneOf: [
                    type: 'string'
                  ,
                    instanceof: 'RegExp'
                  ]
                  description: '''
                  File path from where to extract the content, do not use
                  conjointly with content.
                  '''
                'to':
                  oneOf: [
                    type: 'string'
                  ,
                    instanceof: 'RegExp'
                  ]
                  description: '''
                  Name of the marker until where the content will be replaced.
                  '''
                'match':
                  oneOf: [
                    type: 'string'
                  ,
                    instanceof: 'RegExp'
                  ]
                  description: '''
                  Replace this marker, default to the replaced string if missing.
                  '''
                'replace':
                  type: 'string'
                  description: '''
                  The content to be inserted, used conjointly with the from, to or
                  match options.
                  '''
        required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      # Content: pass all arguments to function calls
      context = arguments[0]
      log message: "Source is \"#{config.source}\"", level: 'DEBUG'
      log message: "Destination is \"#{config.target}\"", level: 'DEBUG'
      config.content = config.content.call @, context if typeof config.content is 'function'
      config.diff ?= config.diff or !!config.stdout
      switch config.eof
        when 'unix'
          config.eof = "\n"
        when 'mac'
          config.eof = "\r"
        when 'windows'
          config.eof = "\r\n"
        when 'unicode'
          config.eof = "\u2028"
      target  = null
      targetContentHash = null
      config.write ?= []
      if config.from? or config.to? or config.match? or config.replace? or config.place_before?
        config.write.push
          from: config.from
          to: config.to
          match: config.match
          replace: config.replace
          append: config.append
          place_before: config.place_before
        config.append = false
      for w in config.write
        if not w.from? and not w.to? and not w.match? and w.replace?
          w.match = w.replace
      # Start work
      if config.source?
        # Option "local" force to bypass the ssh
        # connection, use by the upload function
        source = config.source or config.target
        log message: "Force local source is \"#{if config.local then 'true' else 'false'}\"", level: 'DEBUG'
        {exists} = await @fs.base.exists
          $ssh: false if config.local
          $sudo: false if config.local
          target: source
        unless exists
          throw Error "Source does not exist: #{JSON.stringify config.source}" if config.source
          config.content = ''
        log message: "Reading source", level: 'DEBUG'
        {data: config.content} = await @fs.base.readFile
          $ssh: false if config.local
          $sudo: false if config.local
          target: source
          encoding: config.encoding
      else if not config.content?
        try
          {data: config.content} = await @fs.base.readFile
            $ssh: false if config.local
            $sudo: false if config.local
            target: config.target
            encoding: config.encoding
        catch err
          throw err if err.code isnt 'NIKITA_FS_CRS_TARGET_ENOENT'
          config.content = ''
      # Stat the target
      targetStats = await @call $raw_output: true, ->
        return null unless typeof config.target is 'string'
        log message: "Stat target", level: 'DEBUG'
        try
          {stats} = await @fs.base.lstat target: config.target
          if utils.stats.isDirectory stats.mode
            throw Error 'Incoherent situation, target is a directory and there is no source to guess the filename'
            # config.target = "#{config.target}/#{path.basename config.source}"
            # log message: "Destination is a directory and is now \"config.target\"", level: 'INFO'
            # # Destination is the parent directory, let's see if the file exist inside
            # {stats} = await @fs.base.stat target: config.target, $relax: 'NIKITA_FS_STAT_TARGET_ENOENT'
            # throw Error "Destination is not a file: #{config.target}" unless utils.stats.isFile stats.mode
            # log message: "New target exists", level: 'INFO'
          else if utils.stats.isSymbolicLink stats.mode
            log message: "Destination is a symlink", level: 'INFO'
            if config.unlink
              await @fs.base.unlink target: config.target
              stats = null
          else if utils.stats.isFile stats.mode
            log message: "Destination is a file", level: 'INFO'
          else
            throw Error "Invalid File Type Destination: #{config.target}"
          stats
        catch err
          switch err.code
            when 'NIKITA_FS_STAT_TARGET_ENOENT'
              await @fs.mkdir
                target: path.dirname config.target
                uid: config.uid
                gid: config.gid
                # force execution right on mkdir
                mode: if config.mode then (config.mode | 0o111) else 0o755
            else
              throw err
          null
      # if the transform function returns null or undefined, the file is not written
      # else if transform throws an error, the error isnt caught but rather thrown
      config.content = await config.transform.call undefined, config: config if config.transform
      if config.remove_empty_lines
        log message: "Remove empty lines", level: 'DEBUG'
        config.content = config.content.replace /(\r\n|[\n\r\u0085\u2028\u2029])\s*(\r\n|[\n\r\u0085\u2028\u2029])/g, "$1"
      utils.partial config, log if config.write.length
      if config.eof
        log message: 'Checking option eof', level: 'DEBUG'
        if config.eof is true
          for char, i in config.content
            if char is '\r'
              config.eof = if config.content[i+1] is '\n' then '\r\n' else char
              break
            if char is '\n' or char is '\u2028'
              config.eof = char
              break
          config.eof = '\n' if config.eof is true
          log message: "Option eof is true, guessing as #{JSON.stringify config.eof}", level: 'INFO'
        unless utils.string.endsWith config.content, config.eof
          log message: 'Add eof', level: 'INFO'
          config.content += config.eof
      # Read the target, compute its hash and diff its content
      if targetStats
        {data: targetContent} = await @fs.base.readFile
          target: config.target
          encoding: config.encoding
        targetContentHash = utils.string.hash targetContent
      if config.content?
        contentChanged = not targetStats? or targetContentHash isnt utils.string.hash config.content
      if contentChanged
        {raw, text} = utils.diff targetContent, config.content, config
        config.diff text, raw if typeof config.diff is 'function'
        log type: 'diff', message: text, level: 'INFO'
      if config.backup and contentChanged
        log message: "Create backup", level: 'INFO'
        config.backup_mode ?= 0o0400
        backup = if typeof config.backup is 'string' then config.backup else ".#{Date.now()}"
        await @fs.copy
          $relax: 'NIKITA_FS_STAT_TARGET_ENOENT'
          source: config.target
          target: "#{config.target}#{backup}"
          mode: config.backup_mode
      # Call the target with the content when a function
      if typeof config.target is 'function'
        log message: 'Write target with user function', level: 'INFO'
        await config.target content: config.content
      else
        # Ownership and permission are also handled
        # Preserved the file mode if the file exists. Otherwise,
        # delegate to fs.createWriteStream` the creation of the default
        # mode of "744".
        # https://github.com/nodejs/node/issues/1104
        # `mode` specifies the permissions to use in case a new file is created.
        if contentChanged
          await @call ->
            config.flags ?= 'a' if config.append
            await @fs.base.writeFile
              target: config.target
              flags: config.flags
              content: config.content
              mode: targetStats?.mode
            $status: true
        if config.mode
          await @fs.chmod
            target: config.target
            stats: targetStats
            mode: config.mode
        else if targetStats
          await @fs.chmod
            target: config.target
            stats: targetStats
            mode: targetStats.mode
        # Option gid is set at runtime if target is a new file
        await @fs.chown
          $if: config.uid? or config.gid?
          target: config.target
          stats: targetStats
          uid: config.uid
          gid: config.gid
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    path = require 'path'
    utils = require './utils'

[diffLines]: https://github.com/kpdecker/jsdiff
