
# `nikita.fs.base.readdir`

Reads the contents of a directory. The implementation is conformed with the
Node.js native
[`fs.readir`](https://nodejs.org/api/fs.html#fs_fs_readdir_path_options_callback)
function.
  
## Output parameters

* `files` ([fs.Dirent])   
  List of the names of the files in the directory excluding '.' and '..'

## Examples

Return an array of files if only the target options is provided:

```js
const {files} = await nikita
.fs.base.mkdir('/parent/dir/a_dir')
.fs.base.writeFile('/parent/dir/a_file', '')
.fs.base.readdir("/parent/dir/a_dir")
assert(files, ['my_dir', 'my_file'])
```

Return an array of `Dirent` objects if the `withFileTypes` options is provided:

```js
const {files} = await nikita
.fs.base.writeFile('/parent/dir/a_file', '')
.fs.base.readdir({
  target: "/parent/dir/a_dir",
  withFileTypes: true
})
assert(files[0].name, 'a_file')
assert(files[0].isFile(), true)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.extended ?= config.withFileTypes if config.withFileTypes?

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          extended:
            type: 'boolean'
            description: '''
            Result contain fs.Dirent objects.
            '''
          target:
            type: 'string'
            description: '''
            Path of the directory to read.
            '''
          withFileTypes:
            type: 'boolean'
            description: '''
            Alias of `extended` named after the Node.js native function.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      # Note: -w work on macos, not on linux, it force raw printing of
      # non-printable characters. This is the default when output is not to a
      # terminal.
      opts = [
        '1'                    # (The numeric digit ``one''.)  Force output to be one entry per line.  This is the default when output is not to a terminal.
        'a'                    # Include directory entries whose names begin with a dot (.)
        'n' if config.extended # Display user and group IDs numerically, rather than converting to a user or group name in a long (-l) output.  This option turns on the -l option.
        'l' if config.extended
      ].join('')
      try
        # List the directory
        {stdout} = await @execute
          command: """
          [ ! -d '#{config.target}' ] && exit 2
          ls -#{opts} #{config.target}
          """
        # Convert the output into a `files` array
        files:
          utils.string.lines stdout
          .filter (line, i) -> not config.extended or i isnt 0 # First line in extended mode
          .filter (line) -> line isnt '' # Empty lines
          .map (line, i) ->
            unless config.extended
              name: line
            else
              [, perm,, name] = /^(.+?)\s+.*?(\d+:\d+)\s+(.+)$/.exec line
              name: name
              type: switch perm[0]
                when 'b' then constants.UV_DIRENT_BLOCK  # Block special file.
                when 'c' then constants.UV_DIRENT_CHAR   # Character special file.
                when 'd' then constants.UV_DIRENT_DIR    # Directory.
                when 'l' then constants.UV_DIRENT_LINK   # Symbolic link.
                when 's' then constants.UV_DIRENT_SOCKET # Socket link.
                when 'p' then constants.UV_DIRENT_FIFO   # FIFO.
                else          constants.UV_DIRENT_FILE # Regular file.
          .filter ({name}) -> name isnt '' and name isnt '.' and name isnt '..'
          .map (file) ->
            if config.extended then new Dirent(file.name, file.type) else file.name
      catch err
        if err.exit_code is 2
          throw NIKITA_FS_READDIR_TARGET_ENOENT config: config, err: err
        else
          throw err
        throw err

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions

## Errors

    errors =
      NIKITA_FS_READDIR_TARGET_ENOENT = ({config, err}) ->
        utils.error 'NIKITA_FS_READDIR_TARGET_ENOENT', [
          'fail to read a directory, target is not a directory,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'rmdir'
          path: config.target

## Dependencies

    utils = require '../../../utils'
    {Dirent, constants} = require 'fs'
