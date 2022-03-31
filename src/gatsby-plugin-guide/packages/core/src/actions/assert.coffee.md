
# `nikita.assert`

Assert an action return `true` or an array with all items equals to `true`.

When calling children, ensure they return `true` and that the value is not altered
with the `raw_output` metadata.

When the `not` option is active and if an array is returned, all the items must
equals `false` for the assertion to succeed.

## Casting rules

Casting is activated by default and is disabled when the `strict` configuration
is active.

- Strings and buffers are `true` unless empty
- Numbers above `0` are `true`
- Values of `null` and `undefined` are `false`
- Object literals are `true` if they contain keys
- Function are invalid and throw a `NIKITA_ASSERT_INVALID_OUTPUT` error

## Examples

Assert succeed when the handler return `true`:

```js
nikita.assert( () => {
  return true
})
```

Assert succeed when the handler return a promise which resolves with `true`:

```js
nikita.assert( () => {
  return new Promise( (resolve) => {
    resolve(true)
  })
})
```

## Hooks

    on_action = (action) ->
      action.handler = ( (handler) -> ({config}) ->
        result = await @call
          $raw_output: true
          $handler: handler
        result = [result] unless Array.isArray result
        unless config.strict
          result = then result.map (res) ->
            switch typeof res
              when 'undefined' then false
              when 'boolean' then !!res
              when 'number' then !!res
              when 'string' then !!res.length
              when 'object'
                if Buffer.isBuffer res then !!res.length
                else if res is null then false
                else !!Object.keys(res).length
              when 'function'
                throw utils.error 'NIKITA_ASSERT_INVALID_OUTPUT', [
                  'assertion does not accept functions'
                ]
        result = not result.some (res) ->
          unless config.not
          then res isnt true
          else res is true
        throw utils.error 'NIKITA_ASSERT_UNTRUE', [
          'assertion did not validate,'
          "got #{JSON.stringify result}"
        ] unless result is true
      )(action.handler)

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'not':
            type: 'boolean'
            default: false
            description: '''
            Negates the validation.
            '''
          'strict':
            type: 'boolean'
            default: false
            description: '''
            Cancel the casting of output into a boolean value.
            '''

## Exports

    module.exports =
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
