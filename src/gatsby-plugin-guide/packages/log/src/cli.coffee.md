
# `nikita.log.cli`

Write log to the host filesystem in a user provided format.

## Example with the depth_max option

```js
nikita
.log.cli({
  colors: true,
  depth_max: 2
})
.call({
  metadata: { 
    header: 'Print my header'
  }
}, function(){
  @call({
    metadata: {
      header: 'Print sub header'
    }
  }, function(){
    @call({
      metadata: {
        header: 'Header not printed'
      }
    }, function(){
      // do sth
    })
  })
})
```

## Example with global config

```js
nikita
.log.cli({ colors: true })
.call({
  metadata: {
    header: 'Print my header'
  }
}, function(){
  // do sth
})
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'color':
            oneOf: [
              type: 'boolean'
            ,
              type: 'object'
              properties:
                'status_error':
                  typeof: 'function'
                  description: 'Format the provided argument string on error.'
                'status_false':
                  typeof: 'function'
                  description: 'Format the provided argument string when status is false.'
                'status_true':
                  typeof: 'function'
                  description: 'Format the provided argument string when status is true.'
            ]
            description: '''
            Activate or desactivate color output. The default is to detect if
            there is a tty. For finer control, the formating function can be
            defined inside an object.
            '''
          'depth_max':
            type: ['boolean', 'number']
            default: false
            description: '''
            Disable logging after a provided depth where the depth correponds to
            the number of headers. It is desactivated by default with `false`.
            '''
          'divider':
            type: 'string'
            default: ' : '
            description: '''
            Separator between headers.
            '''
          'enabled':
            type: 'boolean'
            default: true
            description: '''
            Activate or desactivate logging.
            '''
          'end':
            $ref: 'module://@nikitajs/log/src/stream#/definitions/config/properties/end'
            default: false
            description: '''
            Close the stream when the Nikita session terminates. The default
            is to not close the stream for this action, in opposite to the default
            `log.stream` action, because the default stream is `process.stderr`
            which is expected to remain open.
            '''
          'host':
            type: 'string'
            description: '''
            Hostname to display. When not defined, the default is to print the ssh
            hostname or IP or `local` when the action is executed locally.
            '''
          'pad':
            type: 'object'
            default: {}
            description: '''
            Width of the columns, unconstrained layout by default.
            '''
            properties:
              'header':
                type: 'integer'
                description: 'Width of the header column.'
              'host':
                type: 'integer'
                description: 'Width of the host column.'
              'time':
                type: 'integer'
                description: 'Width of the time column.'
          'time':
            type: 'boolean'
            default: true
            description: '''
            Print the action execution time.
            '''
          'separator':
            oneOf: [
              type: 'string'
            ,
              type: 'object'
              properties:
                'host':
                  type: 'integer'
                  description: 'Separator for the host column.'
                'header':
                  type: 'integer'
                  description: 'Separator for the header column.'
                'time':
                  type: 'integer'
                  description: 'Separator for the time column.'
            ]
            default: {}
            description: '''
            Separator between columns. A string value apply the same separator
            while it is also possible to target a specific sperator per column
            by setting an object.
            '''
          'serializer':
            $ref: 'module://@nikitajs/log/src/stream#/definitions/config/properties/serializer'
            default: {}
            description: '''
            Internal property, expose access to the serializer object passed
            to the `log.stream` action.
            '''
          'stream':
            $ref: 'module://@nikitajs/log/src/stream#/definitions/config/properties/stream'
            description: '''
            The writable stream where to print the logs, default to
            `process.stderr`.
            '''
       
* `stream` (stream.Writable)  

Global config can be alternatively set with the "log_cli" property.

## Handler

    handler = ({config, metadata, ssh, tools: {find}}) ->
      # Normalize
      config.stream ?= process.stderr
      config.separator = host: config.separator, header: config.separator if typeof config.separator is 'string'
      config.separator.host ?= unless config.pad.host? then '   ' else ' '
      config.separator.header ?= unless config.pad.header? then '   ' else ' '
      config.separator.time ?= unless config.pad.time? then '  ' else ' '
      config.colors ?= process.stdout.isTTY
      config.colors = {
        status_true: colors.green
        status_false: colors.cyan.dim
        status_error: colors.red
      } if config.colors is true
      # Events
      ids = {}
      format_line = ({host, header, status, time}) ->
        host = pad host, config.pad.host if config.pad.host
        header = pad header, config.pad.header if config.pad.header
        time = pad time, config.pad.time if config.pad.time
        [
          host, config.separator.host
          header, config.separator.header
          status, if config.time then config.separator.time else ''
          time
        ].join ''
      serializer =
        'nikita:action:start': ({action}) ->
          return unless config.enabled
          headers = get_headers action
          return if config.depth_max and config.depth_max < headers.length
          ids[action.metadata.index] = action
          null
        'nikita:resolved': ({action}) ->
          color = if config.colors
          then config.colors.status_true
          else false
          line = format_line
            host: config.host or action.ssh?.config?.host or 'local'
            header: ''
            status: '♥'
            time: ''
          line = color line if color
          return line+'\n'
        'nikita:rejected': ({action, error}) ->
          color = if config.colors
          then config.colors.status_error
          else false
          line = format_line
            host: config.host or action.ssh?.config?.host or 'local'
            header: ''
            status: '✘'
            time: ''
          line = color line if color
          return line+'\n'
        'nikita:action:end': ({action, error, output}) ->
          return unless action.metadata.header
          return if config.depth_max and config.depth_max < action.metadata.depth
          # TODO: I don't like this, the `end` event should receive raw output
          # with error not placed inside output by the history plugin
          error = error or action.metadata.relax and output.error
          status = if error then '✘' else if output?.$status and not action.metadata.shy then '✔' else '-'
          color = false
          if config.colors
            color = if error then config.colors.status_error
            else if output?.$status then config.colors.status_true
            else config.colors.status_false
          return null if action.metadata.disabled
          headers = get_headers action
          line = format_line
            host: config.host or action.ssh?.config?.host or 'local'
            header: headers.join config.divider
            status: status
            time: if config.time then utils.string.print_time action.metadata.time_end - action.metadata.time_start else ''
          line = color line if color
          return line+'\n'
      config.serializer = merge serializer, config.serializer
      @log.stream config

## Exports

    module.exports =
      ssh: false
      handler: handler
      metadata:
        argument_to_config: 'enabled'
        definitions: definitions

## Dependencies

    colors = require 'colors/safe'
    {merge} = require 'mixme'
    pad = require 'pad'
    utils = require '@nikitajs/core/lib/utils'

    get_headers = (action) ->
      walk = (parent) ->
        precious = parent.metadata.header
        results = []
        results.push precious unless precious is undefined
        results.push ...(walk parent.parent) if parent.parent
        results
      headers = walk action
      headers.reverse()
