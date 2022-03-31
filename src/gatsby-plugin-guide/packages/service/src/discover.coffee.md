
# `nikita.service.discover`

Discover the OS init loader.
For now it only supports Centos/Redhat OS in version 6 or 7, Ubuntu.
Store properties in the nikita state object.

## Output
 
* `$status`   
  Indicate a change in service such as a change in installation, update, 
  start/stop or startup registration.   
* `loader`   
  the init loader name   

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'strict':
            type: 'boolean'
            default: false
            description: '''
            Throw an error if the OS is not supported.
            '''
          'shy':
            type: 'boolean'
            default: true
          'cache':
            type: 'boolean'
            default: true
            description: '''
            Disable cache.
            '''

## Handler

    handler = ({config, parent: {state}}) ->
      detected = false
      loader = null
      unless state['nikita:service:loader']?
        try
          data = await @execute
            $shy: config.shy
            command: """
            if command -v systemctl >/dev/null; then exit 1; fi ;
            if command -v service >/dev/null; then exit 2; fi ;
            exit 3 ;
            """
            code: [1, 2]
          loader = switch data.code
            when 1 then 'systemctl'
            when 2 then 'service'
          state['nikita:service:loader'] = loader if config.cache
          loader = state['nikita:service:loader']? if config.cache and not loader?
          $status: data.status, loader: loader
        catch err
          throw Error "Undetected Operating System Loader" if err.exit_code is 3 and config.strict

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
