
# `nikita.log.fs`

Write log to the host filesystem in a user provided format.

## Layout

By default, a file name "{ssh.host}.log" over SSH or "local.log" will be created
inside the base directory defined by the option "basedir". The path looks like
"{config.basedir}/{config.filename}.log".

If the option "archive" is activated, a folder named after the current time is
created inside the base directory. A symbolic link named as "latest" will point
this is direction. The paths look like
"{config.basedir}/{time}/{config.filename}.log" and "{config.basedir}/latest".

## Hooks

    on_action =
      before: [
        '@nikitajs/core/lib/plugins/metadata/schema'
      ]
      after: [
        '@nikitajs/core/lib/plugins/ssh'
      ]
      handler: ({config, ssh}) ->
        # With ssh, filename contain the host or ip address
        config.filename ?= "#{ssh?.config?.host or 'local'}.log"
        # Log is always local
        config.ssh = false

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'archive':
            type: 'boolean'
            default: false
            description: '''
            Save a copy of the previous logs inside a dedicated directory.
            '''
          'basedir':
            type: 'string'
            # default: './log'
            description: '''
            Directory where to store logs relative to the process working
            directory. Default to the "log" directory. Note, when the `archive`
            option is activated, the log files will be stored accessible from
            "./log/latest".
            '''
          'filename':
            type: 'string'
            description: '''
            Name of the log file. It could contain the directory path as well.
            It defaults to `local.log` locally or `{hostname}.log` on a remote
            connection.
            '''
          'serializer':
            type: 'object'
            description: '''
            An object of key value pairs where keys are the event types and the
            value is a function which must be implemented to serialize the
            information.
            '''
        required: ['serializer']

## Handler

    handler = ({config}) ->
      # Normalization
      logdir = path.dirname config.filename
      logdir = path.resolve config.basedir, logdir if config.basedir
      # Archive config
      if config.archive
        latestdir = path.resolve logdir, 'latest'
        now = new Date()
        config.archive = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2) if config.archive is true
        logdir = path.resolve config.basedir, config.archive
      try
        await @fs.base.mkdir logdir, ssh: false
      catch err
        throw err unless err.code is 'NIKITA_FS_MKDIR_TARGET_EEXIST'
      # Events
      config.stream ?= fs.createWriteStream path.resolve logdir, path.basename config.filename
      await @log.stream config
      # Handle link to latest directory
      await @fs.base.symlink
        $if: latestdir
        source: logdir
        target: latestdir

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    fs = require 'fs'
    path = require 'path'
