
# `nikita.wait`

Wait for some time before executing the following action. Internally, this is a
simple action that calls setTimeout. Thus, time is in millisecond.

## Example

```js
before = Date.now()
const {$status} = await nikita.wait({
  time: 5000
})
throw Error 'TOO LATE!' if (Date.now() - before) > 5200
throw Error 'TOO SOON!' if (Date.now() - before) < 5000
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'time':
            type: 'integer'
            description: '''
            Time in millisecond to wait for.
            '''
        required: ['time']

## Handler

    handler = ({config}) ->
      new Promise (resolve) ->
        setTimeout resolve, config.time

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'time'
        definitions: definitions
