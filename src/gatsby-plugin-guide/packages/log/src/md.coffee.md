
# `nikita.log.md`

Write log to the host filesystem in Markdown.

## Example

```js
nikita(async function(){
  await this.log.md({
    basedir: './logs',
    filename: 'nikita.log'
  })
  await this.call(({tools: {log}}) => {
    log({message: 'hello'})
  })
})
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        allOf: [
          properties:
            divider:
              type: 'string'
              default: ' : '
              description: '''
              The characters used to join the hierarchy of headers to create a
              markdown header.
              '''
            enter:
              type: 'boolean'
              default: true
              description: '''
              Enable or disable the entering messages.
              '''
            serializer:
              type: 'object'
              default: {}
              description: '''
              Internal property, expose access to the serializer object passed
              to the `log.fs` action.
              '''
        ,
          $ref: 'module://@nikitajs/log/src/fs#/definitions/config'
        ]

## Handler

    handler = ({config}) ->
      state = {}
      serializer =
        'diff': (log) ->
          "\n```diff\n#{log.message}```\n" if log.message
        'nikita:action:start': ({action}) ->
          content = []
          # Header message
          if action.metadata.header
            walk = (parent) ->
              precious = parent.metadata.header
              results = []
              results.push precious unless precious is undefined
              results.push ...(walk parent.parent) if parent.parent
              results
            headers = walk action
            header = headers.reverse().join config.divider
            content.push '\n'
            content.push '#'.repeat headers.length
            content.push " #{header}\n"
          # Entering message
          act = action.parent
          bastard = undefined
          while act
            bastard = act.metadata.bastard
            break if bastard isnt undefined
            act = act.parent
          if config.enter and action.metadata.module and action.metadata.log isnt false and bastard isnt true
            content.push [
              '\n'
              'Entering'
              ' '
              "#{action.metadata.module}"
              ' '
              '('
              "#{(action.metadata.position.map (index) -> index + 1).join '.'}"
              ')'
              '\n'
            ].join ''
          content.join ''
        'stdin': (log) ->
          out = []
          if log.message.indexOf('\n') is -1
          then out.push "\nRunning Command: `#{log.message}`\n"
          else out.push "\n```stdin\n#{log.message}\n```\n"
          out.join ''
        # 'stderr': (log) ->
        #   "\n```stderr\n#{log.message}```\n"
        'stdout_stream': (log) ->
          if log.message is null
            state.stdout_count = 0
          else if state.stdout_count is undefined
            state.stdout_count = 1
          else
            state.stdout_count++
          out = []
          out.push '\n```stdout\n' if state.stdout_count is 1
          out.push log.message if state.stdout_count > 0
          out.push '\n```\n' if state.stdout_count is 0
          out.join ''
        'text': (log) ->
          content = []
          content.push "\n#{log.message}"
          content.push " (#{log.depth}.#{log.level}, written by #{log.module})" if log.module and log.module isnt '@nikitajs/core/lib/actions/call'
          content.push "\n"
          content.join ''
      config.serializer = merge serializer, config.serializer
      await @log.fs config

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    {merge} = require 'mixme'
    log_fs = require './fs'
