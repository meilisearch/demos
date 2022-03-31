
session = require '../../session'
utils = require '../../utils'
exec = require 'ssh2-exec'

module.exports =
  name: '@nikitajs/core/src/plugins/conditions/os'
  require: [
    '@nikitajs/core/src/plugins/conditions'
  ]
  hooks:
    'nikita:normalize':
      after: '@nikitajs/core/src/plugins/conditions'
      handler: (action, handler) ->
        ->
          action = await handler.call null, action
          return unless action.conditions
          # Normalize conditions
          for config in [action.conditions.if_os, action.conditions.unless_os]
            continue unless config
            for condition in config
              condition.arch ?= []
              condition.arch = [condition.arch] unless Array.isArray condition.arch
              condition.distribution ?= []
              condition.distribution = [condition.distribution] unless Array.isArray condition.distribution
              condition.version ?= []
              condition.version = [condition.version] unless Array.isArray condition.version
              condition.version = utils.semver.sanitize condition.version, 'x'
              condition.linux_version ?= []
              condition.linux_version = [condition.linux_version] unless Array.isArray condition.linux_version
              condition.linux_version = utils.semver.sanitize condition.linux_version, 'x'
          action
    'nikita:action':
      after: '@nikitajs/core/src/plugins/conditions'
      before: '@nikitajs/core/src/plugins/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        if not final_run
          action.metadata.disabled = true
        action

handlers =
  if_os: (action) ->
    final_run = true
    await session
      $bastard: true
      $parent: action
    , ->
      {$status, stdout} = await @execute
        command: utils.os.command
      return final_run = false unless $status
      [arch, distribution, version, linux_version] = stdout.split '|'
      # Remove patch version (eg. 7.8.12 -> 7.8)
      version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec version
      linux_version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec linux_version
      match = action.conditions.if_os.some (condition) ->
        a = !condition.arch.length || condition.arch.some (value) ->
          # Uses `uname -m` internally.
          # Node.js values: 'arm', 'arm64', 'ia32', 'mips', 'mipsel', 'ppc', 'ppc64', 's390', 's390x', 'x32', and 'x64'
          # `uname` values: see https://en.wikipedia.org/wiki/Uname#Examples
          #
          return true if typeof value is 'string' and value is arch
          return true if value instanceof RegExp and value.test arch
        n = !condition.distribution.length || condition.distribution.some (value) ->
          return true if typeof value is 'string' and value is distribution
          return true if value instanceof RegExp and value.test distribution
        # Arch Linux has only linux_version
        v = !version.length || !condition.version.length || condition.version.some (value) ->
          version = utils.semver.sanitize version, '0'
          return true if typeof value is 'string' and utils.semver.satisfies version, value
          return true if value instanceof RegExp and value.test version
        lv = !condition.linux_version.length || condition.linux_version.some (value) ->
          linux_version = utils.semver.sanitize linux_version, '0'
          return true if typeof value is 'string' and utils.semver.satisfies linux_version, value
          return true if value instanceof RegExp and value.test linux_version
        return a and n and v and lv
      final_run = false unless match
    final_run
  unless_os: (action) ->
    final_run = true
    await session
      $bastard: true
      $parent: action
    , ->
      {$status, stdout} = await @execute
        command: utils.os.command
      return final_run = false unless $status
      [arch, distribution, version, linux_version] = stdout.split '|'
      # Remove patch version (eg. 7.8.12 -> 7.8)
      version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec version
      linux_version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec linux_version
      match = action.conditions.unless_os.some (condition) ->
        a = !condition.arch.length || condition.arch.some (value) ->
          return true if typeof value is 'string' and value is arch
          return true if value instanceof RegExp and value.test arch
        n = !condition.distribution.length || condition.distribution.some (value) ->
          return true if typeof value is 'string' and value is distribution
          return true if value instanceof RegExp and value.test distribution
        # Arch Linux has only linux_version
        v = !version.length || !condition.version.length || condition.version.some (value) ->
          version = utils.semver.sanitize version, '0'
          return true if typeof value is 'string' and utils.semver.satisfies version, value
          return true if value instanceof RegExp and value.test version
        lv = !condition.linux_version.length || condition.linux_version.some (value) ->
          linux_version = utils.semver.sanitize linux_version, '0'
          return true if typeof value is 'string' and utils.semver.satisfies linux_version, value
          return true if value instanceof RegExp and value.test linux_version
        return a and n and v and lv
      final_run = false if match
    final_run
