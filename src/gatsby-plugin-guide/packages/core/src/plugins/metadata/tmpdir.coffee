
# {is_object, is_object_literal} = require 'mixme'
utils = require '../../utils'
os = require 'os'
process = require 'process'
fs = require 'ssh2-fs'
exec = require 'ssh2-exec'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/tmpdir'
  require: [
    '@nikitajs/core/src/plugins/tools/find'
    '@nikitajs/core/src/plugins/tools/path'
  ]
  hooks:
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/ssh'
        '@nikitajs/core/src/plugins/tools/path'
        '@nikitajs/core/src/plugins/metadata/uuid'
      ]
      handler: (action) ->
        {config, metadata, tools} = action
        throw utils.error 'METADATA_TMPDIR_INVALID', [
          'the "tmpdir" metadata value must be a boolean, a function or a string,'
          "got #{JSON.stringify metadata.tmpdir}"
        ] unless typeof metadata.tmpdir in ['boolean', 'function', 'string', 'undefined']
        return unless metadata.tmpdir
        # SSH connection extraction
        ssh = if config.ssh is false
        then undefined
        else await tools.find (action) -> action.ssh
        # tmpdir = if ssh then '/tmp' else os.tmpdir()
        # Generate temporary location
        os_tmpdir = if ssh then '/tmp' else os.tmpdir()
        metadata.tmpdir = switch typeof metadata.tmpdir
          when 'string'
            tools.path.resolve os_tmpdir, metadata.tmpdir
          when 'boolean'
            tools.path.resolve os_tmpdir, 'nikita-'+metadata.uuid
          when 'function'
            metadata.tmpdir = await metadata.tmpdir.call null,
              action: action
              os_tmpdir: os_tmpdir
              tmpdir: 'nikita-'+metadata.uuid
        # Temporary directory creation
        tmpDirInParent = action.parent and await tools.find action.parent, (parent) ->
          return true if parent.metadata.tmpdir is metadata.tmpdir
          undefined
        return if tmpDirInParent
        try
          await fs.mkdir ssh, metadata.tmpdir
          metadata.tmpdir_dispose = true
        catch err
          throw err unless err.code is 'EEXIST'
    'nikita:result':
      before: '@nikitajs/core/src/plugins/ssh'
      handler: ({action}) ->
        {config, metadata, tools} = action
        # Value of tmpdir could still be true if there was an error in
        # one of the on_action hook, such as a invalid schema validation
        return unless typeof metadata.tmpdir is 'string'
        return unless metadata.tmpdir_dispose
        return if metadata.dirty
        # SSH connection extraction
        ssh = if config.ssh is false
        then undefined
        else await tools.find action, (action) -> action.ssh
        # Temporary directory decommissioning
        await new Promise (resolve, reject) ->
          exec ssh, "rm -r '#{metadata.tmpdir}'", (err) ->
            if err then reject err else resolve()
