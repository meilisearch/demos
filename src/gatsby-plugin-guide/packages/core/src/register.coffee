
registry = require './registry'
utils = require './utils'

module.exports =
  '': handler: (->)
  'assert': '@nikitajs/core/src/actions/assert'
  'call':
    '': '@nikitajs/core/src/actions/call'
  'execute':
    '': '@nikitajs/core/src/actions/execute'
    'assert': '@nikitajs/core/src/actions/execute/assert'
    'wait': '@nikitajs/core/src/actions/execute/wait'
  'fs':
    'base':
      'chmod': '@nikitajs/core/src/actions/fs/base/chmod'
      'chown': '@nikitajs/core/src/actions/fs/base/chown'
      'copy': '@nikitajs/core/src/actions/fs/base/copy'
      'createReadStream': '@nikitajs/core/src/actions/fs/base/createReadStream'
      'createWriteStream': '@nikitajs/core/src/actions/fs/base/createWriteStream'
      'exists': '@nikitajs/core/src/actions/fs/base/exists'
      'lstat': '@nikitajs/core/src/actions/fs/base/lstat'
      'mkdir': '@nikitajs/core/src/actions/fs/base/mkdir'
      'readdir': '@nikitajs/core/src/actions/fs/base/readdir'
      'readFile': '@nikitajs/core/src/actions/fs/base/readFile'
      'readlink': '@nikitajs/core/src/actions/fs/base/readlink'
      'rename': '@nikitajs/core/src/actions/fs/base/rename'
      'rmdir': '@nikitajs/core/src/actions/fs/base/rmdir'
      'stat': '@nikitajs/core/src/actions/fs/base/stat'
      'symlink': '@nikitajs/core/src/actions/fs/base/symlink'
      'unlink': '@nikitajs/core/src/actions/fs/base/unlink'
      'writeFile': '@nikitajs/core/src/actions/fs/base/writeFile'
    'assert': '@nikitajs/core/src/actions/fs/assert'
    'chmod': '@nikitajs/core/src/actions/fs/chmod'
    'chown': '@nikitajs/core/src/actions/fs/chown'
    'copy': '@nikitajs/core/src/actions/fs/copy'
    'glob': '@nikitajs/core/src/actions/fs/glob'
    'hash': '@nikitajs/core/src/actions/fs/hash'
    'link': '@nikitajs/core/src/actions/fs/link'
    'mkdir': '@nikitajs/core/src/actions/fs/mkdir'
    'move': '@nikitajs/core/src/actions/fs/move'
    'remove': '@nikitajs/core/src/actions/fs/remove'
    'wait': '@nikitajs/core/src/actions/fs/wait'
  'registry':
    'get':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.get namespace
    'register':
      metadata: raw: true
      handler: ({parent, args: [namespace, action]}) ->
        parent.registry.register namespace, action
    'registered':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.registered namespace
    'unregister':
      metadata: raw: true
      handler: ({parent, args: [namespace]}) ->
        parent.registry.unregister namespace
  'ssh':
    'open': '@nikitajs/core/src/actions/ssh/open'
    'close': '@nikitajs/core/src/actions/ssh/close'
    'root': '@nikitajs/core/src/actions/ssh/root'
  'wait': '@nikitajs/core/src/actions/wait'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
