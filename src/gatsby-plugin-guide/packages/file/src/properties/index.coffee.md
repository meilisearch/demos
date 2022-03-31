
# `nikita.file.properties`

Write a file in the Java properties format.

## Example

Use a custom delimiter with spaces around the equal sign.

```js
const {$status} = await nikita.file.properties({
  target: "/path/to/target.json",
  content: { key: "value" },
  separator: ' = '
  merge: true
})
console.info(`File was written: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'backup':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/backup'
          'comment':
            $ref: 'module://@nikitajs/file/src/properties/read#/definitions/config/properties/comment'
          'content':
            type: 'object'
            default: {}
            description: '''
            List of properties to write.
            '''
          'merge':
            type: 'boolean'
            default: false
            description: '''
            Merges content properties with target file.
            '''
          'local':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/local'
          'separator':
            default: '='
            $ref: 'module://@nikitajs/file/src/properties/read#/definitions/config/properties/separator'
          'sort':
            type: 'boolean'
            default: false
            description: '''
            Sort the properties before writting them.
            '''
          'target':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/target'
          'trim':
            $ref: 'module://@nikitajs/file/src/properties/read#/definitions/config/properties/trim'
        required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      # Trim
      unless config.trim
        fnl_props = config.content
      else
        fnl_props = {}
        for k, v of config.content
          k = k.trim()
          v = v.trim() if typeof v is 'string'
          fnl_props[k] = v
      org_props = {}
      log message: "Merging \"#{if config.merge then 'true' else 'false'}\"", level: 'DEBUG'
      # Read Original
      {exists} = await @fs.base.exists target: config.target
      if exists
        {properties} = await @file.properties.read
          target: config.target
          separator: config.separator
          comment: config.comment
          trim: config.trim
      org_props = properties or {}
      # Diff
      {$status} = await @call ->
        status = false
        keys = {}
        for k in Object.keys(org_props) then keys[k] = true
        for k in Object.keys(fnl_props) then keys[k] = true
        for key in Object.keys keys
          if "#{org_props[key]}" isnt "#{fnl_props[key]}"
            log message: "Property '#{key}' was '#{org_props[k]}' and is now '#{fnl_props[k]}'", level: 'WARN'
            status = true if fnl_props[key]?
        status
      # Merge
      if config.merge
        for k, v of fnl_props
          org_props[k] = fnl_props[k]
        fnl_props = org_props
      # Write data
      keys = if config.sort then Object.keys(fnl_props).sort() else Object.keys(fnl_props)
      data = for key in keys
        if fnl_props[key]?
        then "#{key}#{config.separator}#{fnl_props[key]}"
        else "#{key}" # This is a comment
      await @file
        $shy: true
        target: "#{config.target}"
        content: data.join '\n'
        backup: config.backup
        eof: true
      if config.uid or config.gid
        await @system.chown
          target: config.target
          uid: config.uid
          gid: config.gid
      if config.mode
        await @system.chmod
          target: config.target
          mode: config.mode
      {}

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
