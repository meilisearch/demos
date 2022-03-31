
# `nikita.file.cson`

## Output

* `err`   
  Error object if any.   
* `written`   
  Number of written actions with modifications.   

## Example

```js
const {$status} = await nikita.file.yaml({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
})
console.info(`Content was updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'backup':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/backup'
          'content':
            type: 'object'
            description: '''
            Object to stringify.
            '''
          'encoding':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/encoding'
            default: 'utf8'
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'merge':
            type: 'boolean'
            description: '''
            Read the target if it exists and merge its content.
            '''
          'target':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/target'
            description: '''
            File path where to write content to or a function that returns a valid
            file path.
            '''
          'uid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
        required: ['target', 'content']

## Handler

    handler = ({config, tools: {log}}) ->
      # Start real work
      if config.merge
        log message: "Get Target Content", level: 'DEBUG'
        try
          {data} = await @fs.base.readFile
            target: config.target
            encoding: config.encoding
          data = cson.parse data
          config.content = merge data, config.content
          log message: "Target Merged", level: 'DEBUG'
        catch err
          throw err if err.code isnt 'NIKITA_FS_CRS_TARGET_ENOENT'
          # File does not exists, this is ok, there is simply nothing to merge
          log message: "No Target To Merged", level: 'DEBUG'
      log message: "Serialize Content", level: 'DEBUG'
      await @file
        content: cson.stringify config.content
        target: config.target
        backup: config.backup
        gid: config.gid
        uid: config.uid
        mode: config.mode
      {}

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    {merge} = require 'mixme'
    cson = require('cson')

## Resources

[cson]: https://www.npmjs.com/package/cson
