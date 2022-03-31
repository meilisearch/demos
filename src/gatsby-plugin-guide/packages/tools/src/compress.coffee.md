
# `nikita.tools.compress`

Compress an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', 'tar.xz', 'tar.bz2' and '.zip'.

## Output

* `$status`   
  Value is "true" if file was compressed.   

## Example

```js
const {$status} = await nikita.tools.compress({
  source: '/path/to/file.tgz'
  destation: '/tmp'
})
console.info(`File was compressed: ${$status}`)
```


## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          clean:
            type: 'boolean'
            description: '''
            Remove the source file or directory on completion.
            '''
          format:
            type: 'string'
            enum: ['tgz', 'tar', 'zip', 'bz2', 'xz']
            description: '''
            Compression tool and format to be used.
            '''
          source:
            type: 'string'
            description: '''
            Source of the file or directory to compress.
            '''
          target:
            type: 'string'
            description: '''
            Destination path of the generated archive, default to the source
            parent directory.
            '''
        required: ['source', 'target']

## Handler

    handler = ({config, tools: {path}}) ->
      config.source = path.normalize config.source
      config.target = path.normalize config.target
      dir = path.dirname config.source
      name = path.basename config.source
      # Deal with format option
      if config.format?
        format = config.format
      else
        format = ext_to_type config.target, path
      # Run compression
      output = await @execute switch format
        when 'tgz' then "tar czf #{config.target} -C #{dir} #{name}"
        when 'tar' then "tar cf  #{config.target} -C #{dir} #{name}"
        when 'bz2' then "tar cjf #{config.target} -C #{dir} #{name}"
        when 'xz'  then "tar cJf #{config.target} -C #{dir} #{name}"
        when 'zip' then "(cd #{dir} && zip -r #{config.target} #{name} && cd -)"
      await @fs.remove
        $if: config.clean
        target: config.source
        recursive: true
      output

## Extention to type

Convert a full path, a filename or an extension into a supported compression 
type.

    ext_to_type = (name, path) ->
      if /((.+\.)|^\.|^)(tar\.gz|tgz)$/.test name then 'tgz'
      else if /((.+\.)|^\.|^)tar$/.test name then 'tar'
      else if /((.+\.)|^\.|^)zip$/.test name then 'zip'
      else if /((.+\.)|^\.|^)bz2$/.test name then 'bz2'
      else if /((.+\.)|^\.|^)xz$/.test name then 'xz'
      else
        throw Error "Unsupported Extension: #{JSON.stringify(path.extname name)}"

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
      tools:
        ext_to_type: ext_to_type
