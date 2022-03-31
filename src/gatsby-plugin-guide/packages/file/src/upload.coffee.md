
# `nikita.file.upload`

Upload a file to a remote location. Options are identical to the "write"
function with the addition of the "binary" option.

## Output

* `$status`   
  Value is "true" if file was uploaded.

## Example

```js
const {$status} = await nikita.file.upload({
  source: '/tmp/local_file',
  target: '/tmp/remote_file'
})
console.info(`File was uploaded: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            oneOf:[
              type: 'string'
            ,
              typeof: 'function'
            ]
            description: '''
            Text to be written.
            '''
          'from':
            oneOf:[
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Name of the marker from where the content will be replaced.
            '''
          'gid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/gid'
          'md5':
            type: ['boolean', 'string']
            default: false
            description: '''
            Validate uploaded file with md5 checksum (only for binary upload for
            now), may be the string checksum or will be deduced from source if
            "true".
            '''
          'mode':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chmod#/definitions/config/properties/mode'
          'sha1':
            default: false
            type: ['boolean', 'string']
            description: '''
            Validate uploaded file with sha1 checksum (only for binary upload for
            now), may be the string checksum or will be deduced from source if
            "true".
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
          'uid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/uid'
        required: ['source', 'target']

## Handler

    handler = ({config, tools: {log}}) ->
      if config.md5?
        algo = 'md5'
      else if config.sha1?
        algo = 'sha1'
      else
        algo = 'md5'
      log message: "Source is \"#{config.source}\"", level: 'DEBUG'
      log message: "Destination is \"#{config.target}\"", level: 'DEBUG'
      # Stat the target and redefine its path if a directory
      stats = await @call $raw_output: true, ->
        try
          {stats} = await @fs.base.stat
            $ssh: false
            $sudo: false
            target: config.target
          # Target is a file
          return stats if utils.stats.isFile stats.mode
          # Target is invalid
          throw Error "Invalid Target: expect a file, a symlink or a directory for #{JSON.stringify config.target}" unless utils.stats.isDirectory stats.mode
          # Target is a directory
          config.target = path.resolve config.target, path.basename config.source
          try
            {stats} = await @fs.base.stat
              $ssh: false
              sudo: false
              target: config.target
            return stats if utils.stats.isFile stats.mode
            throw Error "Invalid target: #{config.target}"
          catch err
            return null if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
            throw err
        catch err
          return null if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          throw err
      # Now that we know the real name of the target, define a temporary file to write
      stage_target = "#{config.target}.#{Date.now()}#{Math.round(Math.random()*1000)}"
      {$status} = await @call ->
        return true unless stats
        {hash} = await @fs.hash
          target: config.source
          algo: algo
        hash_source = hash
        {hash} = await @fs.hash
          $ssh: false
          $sudo: false
          target: config.target
          algo: algo
        hash_target = hash
        match = hash_source is hash_target
        log if match
        then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download'
        else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
        not match
      return unless $status
      await @fs.mkdir
        $ssh: false
        $sudo: false
        target: path.dirname stage_target
      await @fs.base.createReadStream
        target: config.source
        stream: (rs) ->
          ws = fs.createWriteStream stage_target
          rs.pipe ws
      await @fs.move
        $ssh: false
        $sudo: false
        source: stage_target
        target: config.target
      log message: "Unstaged uploaded file", level: 'INFO'
      if config.mode?
        await @fs.chmod
          $ssh: false
          $sudo: false
          target: config.target
          mode: config.mode
      if config.uid? or config.gid?
        await @fs.chown
          $ssh: false
          $sudo: false
          target: config.target
          uid: config.uid
          gid: config.gid
      {}

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    fs = require 'fs'
    path = require 'path'
    utils = require './utils'
