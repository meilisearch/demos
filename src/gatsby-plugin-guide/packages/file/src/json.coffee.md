
# `nikita.file.json`

## Example

Merge the destination file with user provided content.

```js
const {$status} = await nikita.file.json({
  target: "/path/to/target.json",
  content: { preferences: { colors: 'blue' } },
  transform: function(data){
    if(data.indexOf('red') < 0){ data.push('red'); }
    return data;
  },
  merge: true,
  pretty: true
})
console.info(`File was merged: ${$status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.pretty = 2 if config.pretty is true

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'backup':
            type: ['boolean', 'string']
            default: false
            description: '''
            Create a backup, append a provided string to the filename extension or
            a timestamp if value is not a string, only apply if the target file
            exists and is modified.
            '''
          'content':
            type: 'object'
            default: {}
            description: '''
            The javascript code to stringify.
            '''
          'merge':
            type: 'boolean'
            description: '''
            Merge the user content with the content of the destination file if it
            exists.
            '''
          'pretty':
            type: ['boolean', 'integer']
            default: false
            description: '''
            Prettify the JSON output, accept the number of spaces as an integer,
            default to none if false or to 2 spaces indentation if true.
            '''
          'source':
            type: 'string'
            description: '''
            Path to a JSON file providing default values.
            '''
          'target':
            type: 'string'
            description: '''
            Path to the destination file.
            '''
          'transform':
            typeof: 'function'
            description: '''
            User provided function to modify the javascript before it is
            stringified into JSON.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      if config.merge
        try
          {data} = await @fs.base.readFile
            target: config.target
            encoding: 'utf8'
          config.content = merge JSON.parse(data), config.content
        catch err
          throw err if err.code isnt 'NIKITA_FS_CRS_TARGET_ENOENT'
      if config.source
        {data} = await @fs.base.readFile
          $ssh: false if config.local
          $sudo: false if config.local
          target: config.source
          encoding: 'utf8'
        config.content = merge JSON.parse(data), config.content
      config.content = config.transform config.content if config.transform
      await @file
        target: config.target
        content: -> JSON.stringify config.content, null, config.pretty
        backup: config.backup
        diff: config.diff
        eof: config.eof
        gid: config.gid
        uid: config.uid
        mode: config.mode
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    {merge} = require 'mixme'
