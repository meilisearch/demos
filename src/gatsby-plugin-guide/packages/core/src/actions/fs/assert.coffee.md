
# `nikita.fs.assert`

Assert a file exists or a provided text match the content of a text file.

## Output

* `err` (Error)   
  Error if assertion failed.   

## Example

Validate the content of a file:

```js
nikita.fs.assert({
  target: '/tmp/a_file', 
  content: 'nikita is around'
})
```

Ensure a file does not exists:

```js
nikita.fs.assert({
  target: '/tmp/a_file',
  not: true
})
```

## Hooks

    on_action = ({config, metadata}) ->
      config.filter = [config.filter] if config.filter instanceof RegExp

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}, {instanceof: 'RegExp'}]
            description: '''
            Text to validate.
            '''
          'encoding':
            type: 'string'
            default: 'utf8'
            description: '''
            Content encoding, see the Node.js supported Buffer encoding.
            '''
          'filetype':
            type: 'array'
            items:
              type: ['integer', 'string']
            description: '''
            Validate the file, could be any [file type
            constants](https://nodejs.org/api/fs.html#fs_file_type_constants) or
            one of 'ifreg', 'file', 'ifdir', 'directory', 'ifchr', 'chardevice',
            'iffblk', 'blockdevice', 'ififo', 'fifo', 'iflink', 'symlink',
            'ifsock',  'socket'.
            '''
          'filter':
            type: 'array'
            items:
              instanceof: 'RegExp'
            description: '''
            Text to filter in actual content before matching.
            '''
          'gid':
            type: ['integer', 'string']
            description: '''
            Group ID to assert.
            '''
          'md5':
            type: 'string'
            description: '''
            Validate signature.
            '''
          'mode':
            type: 'array'
            items:
              $ref: 'module://@nikitajs/core/src/actions/fs/base/chmod#/definitions/config/properties/mode'
            description: '''
            Validate file permissions.
            '''
          'not':
            $ref: 'module://@nikitajs/core/src/actions/assert#/definitions/config/properties/not'
          'sha1':
            type: 'string'
            description: '''
            Validate signature.
            '''
          'sha256':
            type: 'string'
            description: '''
            Validate signature.
            '''
          'target':
            type: 'string'
            description: '''
            Location of the file to assert.
            '''
          'trim':
            type: 'boolean'
            default: false
            description: '''
            Trim the actual and expected content before matching.
            '''
          'uid':
            type: ['integer', 'string']
            description: '''
            User ID to assert.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      config.filetype = for filetype in config.filetype or []
        continue unless filetype
        if typeof filetype is 'string'
          switch filetype.toLowerCase()
            when 'ifreg', 'file' then fs.constants.S_IFREG
            when 'ifdir', 'directory' then fs.constants.S_IFDIR
            when 'ifchr', 'chardevice' then fs.constants.S_IFCHR
            when 'iffblk', 'blockdevice' then fs.constants.S_IFBLK
            when 'ififo', 'fifo' then fs.constants.S_IFIFO
            when 'iflink', 'symlink' then fs.constants.S_IFLNK
            when 'ifsock', 'socket' then fs.constants.S_IFSOCK
            else filetype
        else filetype
      if typeof config.content is 'string'
        config.content = config.content.trim() if config.trim
        config.content = Buffer.from config.content, config.encoding
      else if Buffer.isBuffer config.content
        config.content = utils.buffer.trim config.content, config.encoding if config.trim
      # Assert file exists
      unless config.content? or config.md5 or config.sha1 or config.sha256 or config.mode?.length
        {exists} = await @fs.base.exists config.target.toString()
        unless config.not
          unless exists
            err = errors.NIKITA_FS_ASSERT_FILE_MISSING config: config
        else
          if exists
            err = errors.NIKITA_FS_ASSERT_FILE_EXISTS config: config
        throw err if err
      # Assert file filetype
      if config.filetype?.length
        {stats} = await @fs.base.lstat config.target
        if fs.constants.S_IFREG in config.filetype and not utils.stats.isFile stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'File', stats: stats
        if fs.constants.S_IFDIR in config.filetype and not utils.stats.isDirectory stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'Directory', stats: stats
        if fs.constants.S_IFCHR in config.filetype and not utils.stats.isCharacterDevice stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'Character Device', stats: stats
        if fs.constants.S_IFBLK in config.filetype and not utils.stats.isBlockDevice stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'Block Device', stats: stats
        if fs.constants.S_IFIFO in config.filetype and not utils.stats.isFIFO stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'FIFO', stats: stats
        if fs.constants.S_IFLNK in config.filetype and not utils.stats.isSymbolicLink stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'Symbolic Link', stats: stats
        if fs.constants.S_IFSOCK in config.filetype and not utils.stats.isSocket stats.mode
          throw errors.NIKITA_FS_ASSERT_FILETYPE_INVALID config: config, expect: 'Socket', stats: stats
      # Assert content equal
      if config.content? and (typeof config.content is 'string' or Buffer.isBuffer config.content)
        {data} = await @fs.base.readFile config.target
        for filter in config.filter or []
          data = filter[Symbol.replace] data, ''
        # RegExp returns string
        if typeof data is 'string'
          data = Buffer.from data
        data = utils.buffer.trim data, config.encoding if config.trim
        unless config.not
          unless data.equals config.content
            throw errors.NIKITA_FS_ASSERT_CONTENT_UNEQUAL config: config, expect: data
        else
          if data.equals config.content
            throw errors.NIKITA_FS_ASSERT_CONTENT_EQUAL config: config, expect: data
        throw err if err
      # Assert content match
      if config.content? and config.content instanceof RegExp
        {data} = await @fs.base.readFile config.target
        for filter in config.filter or []
          data = filter[Symbol.replace] data, ''
        data = utils.buffer.trim data, config.encoding if config.trim
        unless config.not
          unless config.content.test data
            throw errors.NIKITA_FS_ASSERT_CONTENT_UNMATCH config: config, expect: data
        else
          if config.content.test data
            throw errors.NIKITA_FS_ASSERT_CONTENT_MATCH config: config, expect: data
        throw err if err
      # Assert hash match
      # todo, also support config.algo and config.hash
      (algo = 'md5'; _hash = config.md5) if config.md5
      (algo = 'sha1'; _hash = config.sha1) if config.sha1
      (algo = 'sha256'; _hash = config.sha256) if config.sha256
      if algo
        {hash} = await @fs.hash config.target, algo: algo
        unless config.not
          if _hash isnt hash
            throw errors.NIKITA_FS_ASSERT_HASH_UNMATCH config: config, algo: algo, hash:
              expected: _hash, actual: hash
        else
          if _hash is hash
            throw errors.NIKITA_FS_ASSERT_HASH_MATCH config: config, algo: algo, hash: hash
      # Assert uid ownerships
      if config.uid?
        {stats} = await @fs.base.lstat config.target
        unless config.not
          unless "#{stats.uid}" is "#{config.uid}"
            throw errors.NIKITA_FS_ASSERT_UID_UNMATCH config: config, actual: stats.uid
        else
          if "#{stats.uid}" is "#{config.uid}"
            throw errors.NIKITA_FS_ASSERT_UID_MATCH config: config
      # Assert gid ownerships
      if config.gid?
        {stats} = await @fs.base.stat config.target
        unless config.not
          unless "#{stats.gid}" is "#{config.gid}"
            throw errors.NIKITA_FS_ASSERT_GID_UNMATCH config: config, actual: stats.gid
        else
          if "#{stats.gid}" is "#{config.gid}"
            throw errors.NIKITA_FS_ASSERT_GID_MATCH config: config
      # Assert file permissions
      if config.mode?.length
        {stats} = await @fs.base.stat config.target
        unless config.not
          unless utils.mode.compare config.mode, stats.mode
            throw errors.NIKITA_FS_ASSERT_MODE_UNMATCH config: config, mode: stats.mode
        else
          if utils.mode.compare config.mode, stats.mode
            throw errors.NIKITA_FS_ASSERT_MODE_MATCH config: config

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
      NIKITA_FS_ASSERT_FILE_MISSING: ({config}) ->
        utils.error 'NIKITA_FS_ASSERT_FILE_MISSING', [
          'file does not exists,'
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_FILE_EXISTS: ({config}) ->
        utils.error 'NIKITA_FS_ASSERT_FILE_EXISTS', [
          'file exists,'
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_FILETYPE_INVALID: ({config, expect, stats}) ->
        utils.error 'NIKITA_FS_ASSERT_FILETYPE_INVALID', [
          'filetype is invalid,'
          "expect #{JSON.stringify expect} type,"
          "got #{JSON.stringify utils.stats.type stats.mode} type,"
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_CONTENT_UNEQUAL: ({config, expect}) ->
        utils.error 'NIKITA_FS_ASSERT_CONTENT_UNEQUAL', [
          'content does not equal the expected value,'
          "expect #{JSON.stringify expect.toString()}"
          "to equal #{JSON.stringify config.content.toString()},"
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_CONTENT_EQUAL: ({config, expect}) ->
        utils.error 'NIKITA_FS_ASSERT_CONTENT_EQUAL', [
          'content is matching,'
          "not expecting to equal #{JSON.stringify expect.toString()},"
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_CONTENT_UNMATCH: ({config, expect}) ->
        utils.error 'NIKITA_FS_ASSERT_CONTENT_UNMATCH', [
          'content does not match the provided regexp,'
          "expect #{JSON.stringify expect.toString()}"
          "to match #{config.content.toString()},"
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_CONTENT_MATCH: ({config, expect}) ->
        utils.error 'NIKITA_FS_ASSERT_CONTENT_MATCH', [
          'content is matching the provided regexp,'
          "got #{JSON.stringify expect.toString()}"
          "to match #{config.content.toString()},"
          "location is #{JSON.stringify config.target}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_HASH_UNMATCH: ({config, algo, hash}) ->
        utils.error 'NIKITA_FS_ASSERT_HASH_UNMATCH', [
          "an invalid #{algo} signature was computed,"
          "expect #{JSON.stringify hash.expected},"
          "got #{JSON.stringify hash.actual}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_HASH_MATCH: ({config, algo, hash}) ->
        utils.error 'NIKITA_FS_ASSERT_HASH_MATCH', [
          "the #{algo} signatures are matching,"
          "not expecting to equal #{JSON.stringify hash}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_MODE_UNMATCH: ({config, mode}) ->
        expect = config.mode.map (mode) -> "#{pad 4, utils.mode.stringify(mode), '0'}"
        utils.error "NIKITA_FS_ASSERT_MODE_UNMATCH", [
          'content permission don\'t match the provided mode,'
          "expect #{expect},"
          "got #{utils.mode.stringify(mode).substr -4}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_MODE_MATCH: ({config}) ->
        expect = config.mode.map (mode) -> "#{pad 4, utils.mode.stringify(mode), '0'}"
        utils.error "NIKITA_FS_ASSERT_MODE_MATCH", [
          'the content permission match the provided mode,'
          "not expecting to equal #{expect}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_UID_UNMATCH: ({config, actual}) ->
        utils.error 'NIKITA_FS_ASSERT_UID_UNMATCH', [
          'the uid of the target does not match the expected value,'
          "expected #{JSON.stringify config.uid},"
          "got #{JSON.stringify actual}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_UID_MATCH: ({config}) ->
        utils.error 'NIKITA_FS_ASSERT_UID_MATCH', [
          'the uid of the target  match the provided value,'
          "not expecting to equal #{JSON.stringify config.uid}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_GID_UNMATCH: ({config, actual}) ->
        utils.error 'NIKITA_FS_ASSERT_GID_UNMATCH', [
          'the gid of the target does not match the expected value,'
          "expected #{JSON.stringify config.uid},"
          "got #{JSON.stringify actual}."
        ], target: config.target, message: config.error
      NIKITA_FS_ASSERT_GID_MATCH: ({config}) ->
        utils.error 'NIKITA_FS_ASSERT_GID_MATCH', [
          'the gid of the target  match the provided value,'
          "not expecting to equal #{JSON.stringify config.uid}."
        ], target: config.target, message: config.error

## Dependencies

    pad = require 'pad'
    fs = require 'fs'
    utils = require '../../utils'
