
# `nikita.service.init`

Render startup script.
Reload the service daemon provider depending on the os.

## Output

* `$status`   
  Indicates if the init script was reloaded.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'backup':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/backup'
          'context':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/context'
            default: {}
            description: '''
            The context object used to render the scripts file; templating is
            disabled if no context is provided.
            '''
          'engine':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/engine'
          'filters':
            typeof: 'function'
            description: '''
            Filter function to extend the nunjucks engine.
            '''
          'gid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/gid'
          'local':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/local'
          'mode':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chmod#/definitions/config/properties/mode'
            default: '755'
          'name':
            type: 'string'
            description: '''
            The name of the destination file. Uses the name of the template if
            missing.
            '''
          'source':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/source'
          'target':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/target'
            description: '''
            The destination file. `/etc/init.d/crond` or
            `/etc/systemd/system/crond.service` for example. If no provided,
            nikita put it on the default folder based on the service daemon
            provider,the OS and use the source filename as the name.
            '''
          'uid':
            $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/uid'
        required: ['source']

## Handler

    handler = ({config, tools: {path}}) ->
      # check if file is target is directory
      # detect daemon loader provider to construct target
      config.name ?= path.basename(config.source).split('.')[0]
      config.name = path.basename(config.target).split('.service')[0] if config.target?
      config.target ?= "/etc/init.d/#{config.name}"
      {loader} = await @service.discover {}
      config.loader ?= loader
      # discover loader to put in cache
      await @file.render
        target: config.target
        source: config.source
        mode: config.mode
        uid: config.uid
        gid: config.gid
        backup: config.backup
        context: config.context
        local: config.local
        engine: config.engine
      return unless config.loader is 'systemctl'
      {$status} = await @execute
        $shy: true
        command: """
          systemctl status #{config.name} 2>\&1 | egrep \
          '(Reason: No such file or directory)|(Unit #{config.name}.service could not be found)|(#{config.name}.service changed on disk)'
          """
        code_skipped: 1
      return unless $status
      await @execute
        command: 'systemctl daemon-reload;systemctl reset-failed'

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

[sysvinit vs systemd]:(https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference)
