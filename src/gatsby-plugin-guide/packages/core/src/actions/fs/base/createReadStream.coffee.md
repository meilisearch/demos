
# `nikita.fs.base.createReadStream`

## Example

The `stream` config property receives the readable stream:

```js
buffers = []
await nikita.fs.base.createReadStream({
  target: '/path/to/file'
  stream: function(rs){
    rs.on('readable', function(){
      while(buffer = rs.read()){
        buffers.push(buffer)
      }
    })
  }
})
console.info(Buffer.concat(buffers).toString())
```

Alternatively, you can directly provide the readable function with the
`on_readable` config property:

```js
buffers = []
await nikita.fs.base.createReadStream({
  target: '/path/to/file'
  on_readable: function(rs){
    while(buffer = rs.read()){
      buffers.push(buffer)
    }
  }
})
console.info(Buffer.concat(buffers).toString())
```

## Hooks

    on_action =
      after: [
        '@nikitajs/core/src/plugins/execute'
      ]
      before: [
        '@nikitajs/core/src/plugins/metadata/schema'
        '@nikitajs/core/src/plugins/metadata/tmpdir'
      ]
      handler: ({config, metadata, tools: {find, walk}}) ->
        config.sudo ?= await find ({metadata: {sudo}}) -> sudo
        metadata.tmpdir ?= true if config.sudo

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'encoding':
            type: 'string'
            enum: require('../../../utils/schema').encodings
            default: 'utf8'
            description: '''
            The encoding used to decode the buffer into a string. The encoding can
            be any one of those accepted by Buffer. When not defined, this action
            return a Buffer instance.
            '''
          'on_readable':
            typeof: 'function'
            description: '''
            User provided function called when the readable stream is created and
            readable. The user is responsible for pumping new content from it. It
            is a short version of `config.stream` which registers the function to
            the `readable` event.
            '''
          'stream':
            typeof: 'function'
            description: '''
            User provided function receiving the newly created readable stream.
            The user is responsible for pumping new content from it.
            '''
          'target':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Source location of the file to read.
            '''
        required: ['target']

## Handler

    handler = ({config, metadata, ssh, tools: {path, log, find}}) ->
      # Normalization
      config.target = if config.cwd then path.resolve config.cwd, config.target else path.normalize config.target
      throw Error "Non Absolute Path: target is #{JSON.stringify config.target}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option" if ssh and not path.isAbsolute config.target
      config.target_tmp ?= "#{metadata.tmpdir}/#{utils.string.hash config.target}" if config.sudo
      throw errors.NIKITA_FS_CRS_NO_EVENT_HANDLER() unless config.on_readable or config.stream
      # Guess current username
      current_username = utils.os.whoami ssh: ssh
      try if config.target_tmp
        await @execute """
          [ ! -f '#{config.target}' ] && exit
          cp '#{config.target}' '#{config.target_tmp}'
          chown '#{current_username}' '#{config.target_tmp}'
          """
        log message: "Placing original file in temporary path before reading", level: 'INFO'
      catch err
        log message: "Failed to place original file in temporary path", level: 'ERROR'
        throw err
      # Read the stream
      log message: "Reading file #{config.target_tmp or config.target}", level: 'DEBUG'
      new Promise (resolve, reject) ->
        buffers = []
        rs = await fs.createReadStream ssh, config.target_tmp or config.target
        if config.on_readable
        then rs.on 'readable', -> config.on_readable rs
        else config.stream rs
        rs.on 'error', (err) ->
          if err.code is 'ENOENT'
            err = errors.NIKITA_FS_CRS_TARGET_ENOENT config: config, err: err
          else if err.code is 'EISDIR'
            err = errors.NIKITA_FS_CRS_TARGET_EISDIR config: config, err: err
          else if err.code is 'EACCES'
            err = errors.NIKITA_FS_CRS_TARGET_EACCES config: config, err: err
          reject err
        rs.on 'end', resolve

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        tmpdir: true
        definitions: definitions

## Errors

    errors =
      NIKITA_FS_CRS_NO_EVENT_HANDLER: ->
        utils.error 'NIKITA_FS_CRS_NO_EVENT_HANDLER', [
          'unable to consume the readable stream,'
          'one of the "on_readable" or "stream"'
          'hooks must be provided'
        ]
      NIKITA_FS_CRS_TARGET_ENOENT: ({err, config}) ->
        utils.error 'NIKITA_FS_CRS_TARGET_ENOENT', [
          'fail to read a file because it does not exist,'
          unless config.target_tmp
          then "location is #{JSON.stringify config.target}."
          else "location is #{JSON.stringify config.target_tmp} (temporary file, target is #{JSON.stringify config.target})."
        ],
          errno: err.errno
          syscall: err.syscall
          path: err.path
      NIKITA_FS_CRS_TARGET_EISDIR: ({err, config}) ->
        utils.error 'NIKITA_FS_CRS_TARGET_EISDIR', [
          'fail to read a file because it is a directory,'
          unless config.target_tmp
          then "location is #{JSON.stringify config.target}."
          else "location is #{JSON.stringify config.target_tmp} (temporary file, target is #{JSON.stringify config.target})."
        ],
          errno: err.errno
          syscall: err.syscall
          path: config.target_tmp or config.target # Native Node.js api doesn't provide path
      NIKITA_FS_CRS_TARGET_EACCES: ({err, config}) ->
        utils.error 'NIKITA_FS_CRS_TARGET_EACCES', [
          'fail to read a file because permission was denied,'
          unless config.target_tmp
          then "location is #{JSON.stringify config.target}."
          else "location is #{JSON.stringify config.target_tmp} (temporary file, target is #{JSON.stringify config.target})."
        ],
          errno: err.errno
          syscall: err.syscall
          path: config.target_tmp or config.target # Native Node.js api doesn't provide path

## Dependencies

    fs = require 'ssh2-fs'
    utils = require '../../../utils'
