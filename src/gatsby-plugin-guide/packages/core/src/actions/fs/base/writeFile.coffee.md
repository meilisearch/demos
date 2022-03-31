
# `nikita.fs.base.writeFile`

Write a Buffer or a string to a file. This action mimic the behavior of the
Node.js native [`fs.writeFile`](https://nodejs.org/api/fs.html#fs_fs_writefile_file_data_options_callback)
function.

Internally, it uses the `nikita.fs.createWriteStream` from which it inherits all
the configuration properties.

## Example

```js
nikita.fs.base.writeFile({
  target: "/tmp/a_file",
  content: 'Some data, a string or a Buffer'
})
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Content to write.
            '''
          'cwd':
            type: 'string'
            description: '''
            Current working directory used to resolve a relative target path.
            '''
          'flags':
            type: 'string'
            default: 'w'
            description: '''
            File system flag as defined in the [Node.js
            documentation](https://nodejs.org/api/fs.html#fs_file_system_flags)
            and [open(2)](http://man7.org/linux/man-pages/man2/open.2.html)
            '''
          'target_tmp':
            type: 'string'
            description: '''
            Location where to write the temporary uploaded file before it is
            copied into its final destination, default to
            "{tmpdir}/nikita_{YYMMDD}_{pid}_{rand}/{hash target}"
            '''
          'mode':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/createWriteStream#/definitions/config/properties/mode'
          'target':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Final destination path.
            '''
        required: ['content', 'target']

## Handler

    handler = ({config, tools: {path}, ssh}) ->
      # Normalization
      config.target = if config.cwd then path.resolve config.cwd, config.target else path.normalize config.target
      throw NIKITA_FS_STAT_TARGET_ENOENT config: config, err: err if ssh and not path.isAbsolute config.target
      # Real work
      await @fs.base.createWriteStream
        target: config.target
        flags: config.flags
        mode: config.mode
        stream: (ws) ->
          ws.write config.content
          ws.end()

## Errors

    errors =
      NIKITA_FS_STAT_TARGET_ENOENT: ({config, err}) ->
        utils.error 'NIKITA_FS_TARGET_INVALID', [
          'the target location is absolute'
          'but this is not suported in SSH mode,'
          'you must provide an absolute path or the cwd option,'
          "got #{JSON.stringify config.target}"
        ],
          exit_code: err.exit_code
          errno: -2
          syscall: 'rmdir'
          path: config.target

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions

## Dependencies

    utils = require '../../../utils'
