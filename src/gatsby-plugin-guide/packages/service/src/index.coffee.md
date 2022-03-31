
# `nikita.service`

Install, start/stop/restart and startup a service.

The config "state" takes 3 possible values: "started", "stopped" and
"restarted". A service will only be restarted if it leads to a change of status.
Set the value to "['started', 'restarted']" to ensure the service will be always
started.

## Output

* `$status`   
  Indicate a change in service such as a change in installation, update,
  start/stop or startup registration.
* `installed`   
  List of installed services.
* `updates`   
  List of services to update.

## Example

```js
const {$status} = await nikita.service([{
  name: 'ganglia-gmetad-3.5.0-99',
  srv_name: 'gmetad',
  state: 'stopped',
  startup: false
},{
  name: 'ganglia-web-3.5.7-99'
}])
console.info(`Service status: ${$status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.state = config.state.split(',') if typeof config.state is 'string'

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cache':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/cacheonly'
          'cacheonly':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/cacheonly'
          'chk_name':
            type: 'string'
            description: '''
            Name used by the chkconfig utility, default to "srv_name" and "name".
            '''
          'installed':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/installed'
          'name':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/name'
          'outdated':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/outdated'
          'pacman_flags':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/pacman_flags'
          'srv_name':
            type: 'string'
            description: '''
            Name used by the service utility, default to "name".
            '''
          'startup':
            type: ['boolean', 'string']
            description: '''
            Run service daemon on startup. If true, startup will be set to '2345',
            use an empty string to not define any run level.
            '''
          'state':
            type: 'array'
            items:
              type: 'string'
              enum: ['started', 'stopped', 'restarted']
            description: '''
            Ensure the service in the requested state.
            '''
          'yaourt_flags':
            $ref: 'module://@nikitajs/service/src/install#/definitions/config/properties/yaourt_flags'
          'yum_name':
            type: 'string'
            description: '''
            Name used by the yum utility, default to "name".
            '''
        dependencies:
          'state':
            anyOf: [
              required: ['name']
            ,
              required: ['srv_name']
            ,
              required: ['chk_name']
            ]
          'startup':
            anyOf: [
              required: ['name']
            ,
              required: ['srv_name']
            ,
              required: ['chk_name']
            ]
        
## Handler

    handler = ({config, parent, state}) ->
      pkgname = config.yum_name or config.name
      chkname = config.chk_name or config.srv_name or config.name
      srvname = config.srv_name or config.chk_name or config.name
      if pkgname  # option name and yum_name are optional, skill installation if not present
        await @service.install
          name: pkgname
          cache: config.cache
          cacheonly: config.cacheonly
          installed: config.installed
          outdated: config.outdated
          pacman_flags: config.pacman_flags
          yaourt_flags: config.yaourt_flags
        parent.state = merge parent.state, state
      if config.startup?
        await @service.startup
          name: chkname
          startup: config.startup
      if config.state
        {$status} = await @service.status
          $shy: true
          name: srvname
        if not $status and 'started' in config.state
          await @service.start
            name: srvname
        if $status and 'stopped' in config.state
          await @service.stop
            name: srvname
        if $status and 'restarted' in config.state
          await @service.restart
            name: srvname

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'name'
        definitions: definitions

## Dependencies

    {merge} = require 'mixme'
