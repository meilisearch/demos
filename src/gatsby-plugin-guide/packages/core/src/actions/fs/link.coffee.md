
# `nikita.fs.link`

Create a symbolic link and it's parent directories if they don't yet
exist.

Note, it is valid for the "source" file to not exist.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if link was created or modified.   

## Example

```js
const {$status} = await nikita.fs.link({
  source: __dirname,
  target: '/tmp/a_link'
})
console.info(`Link was created: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'source':
            type: 'string'
            description: '''
            Referenced file to be linked.
            '''
          'target':
            type: 'string'
            description: '''
            Symbolic link to be created.
            '''
          'exec':
            type: 'boolean'
            description: '''
            Create an executable file with an `exec` command.
            '''
          'mode':
            $ref: 'module://@nikitajs/core/src/actions/fs/base/chmod#/definitions/config/properties/mode'
        required: ['source', 'target']

## Handler

    handler = ({config, tools: {path}}) ->
      # Set default
      config.mode ?= 0o0755
      # It is possible to have collision if two symlink
      # have the same parent directory
      await @fs.base.mkdir
        target: path.dirname config.target
        $relax: 'NIKITA_FS_MKDIR_TARGET_EEXIST'
      if config.exec
        exists = await @call $raw_output: true, ->
          {exists} = await @fs.base.exists target: config.target
          return false unless exists
          {data} = await @fs.base.readFile
            target: config.target
            encoding: 'utf8'
          exec_command = /exec (.*) \$@/.exec(data)[1]
          exec_command and exec_command is config.source
        return if exists
        content = """
        #!/bin/bash
        exec #{config.source} $@
        """
        await @fs.base.writeFile
          target: config.target
          content: content
        await @fs.base.chmod
          target: config.target
          mode: config.mode
      else
        exists = await @call $raw_output: true, ->
          try
            {target} = await @fs.base.readlink target: config.target
            return true if target is config.source
            await @fs.base.unlink target: config.target
            false
          catch err
            false
        return if exists
        await @fs.base.symlink
          source: config.source
          target: config.target
      true

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../../utils'
    {escapeshellarg} = utils.string
