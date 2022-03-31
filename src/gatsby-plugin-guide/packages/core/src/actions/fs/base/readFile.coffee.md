
# `nikita.fs.base.readFile`

## Example

```js
const {data} = await nikita.fs.base.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'encoding':
            type: 'string'
            enum: require('../../../utils/schema').encodings
            description: '''
            The encoding used to decode the buffer into a string. The encoding can
            be any one of those accepted by Buffer. When not defined, this action
            return a Buffer instance.
            '''
          'target':
            oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
            description: '''
            Source location of the file to read.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      # Normalize options
      buffers = []
      await @fs.base.createReadStream
        target: config.target
        on_readable: (rs) ->
          while buffer = rs.read()
            buffers.push buffer
      data = Buffer.concat buffers
      data = data.toString config.encoding if config.encoding
      data: data

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'target'
        log: false
        raw_output: true
        definitions: definitions
