
# `nikita.file.render`

Render a template file. More templating engine could be added on demand. The
following templating engines are integrated:

* [Handlebars](https://handlebarsjs.com/)

If target is a callback, it will be called with the generated content as
its first argument.   

## Output

* `$status`   
  Value is true if rendered file was created or modified.

## Rendering with Handlebar

```js
const {$status} = await nikita.file.render({
  source: './some/a_template.hbs',
  target: '/tmp/a_file',
  context: {
    username: 'a_user'
  }
})
console.info(`File was rendered: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      # Validate parameters
      config.encoding ?= 'utf8'
      throw Error 'Required option: source or content' unless config.source or config.content
      # Extension
      if not config.engine and config.source
        extension = path.extname config.source
        switch extension
          when '.hbs' then config.engine = 'handlebars'
          else throw Error "Invalid Option: extension '#{extension}' is not supported"

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'content':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/content'
          'context':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/context'
          'engine':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/engine'
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'local':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/local'
          'remove_empty_lines':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/remove_empty_lines'
          'source':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/source'
          'target':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/target'
          'uid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
        required: ['target', 'context']

## Handler

    handler = ({config, tools: {log}}) ->
      # Read source
      if config.source
        {data} = await @fs.base.readFile
          $ssh: false if config.local
          $sudo: false if config.local
          target: config.source
          encoding: config.encoding
        if data?
          config.source = undefined
          config.content = data
      log message: "Rendering with #{config.engine}", level: 'DEBUG'
      config.transform = ({config}) ->
        template = handlebars.compile config.content.toString()
        template config.context
      await @file config
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
        templated: false

## Dependencies

    path = require 'path'
    handlebars = require 'handlebars'
