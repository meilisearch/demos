---
navtitle: Handler
sort: 2
---

# Metadata "handler"

The `handler` action property defines the function that an action implements to get things done. It is fundamental to each action.

The property is required but most of the time, you don't have to write a handler function on your own. Instead, you can use an existing action which was previously [registered](/current/guide/registry/).

However, you should not be afraid to write your own handler, it is as easy as writing a plain vanilla JavaScript function and using the Nikita `call` action to schedule its execution.

## Usage

You can pass the `$handler` property name when calling an action along with its configuration.

The [configuration properties](/current/api/config/) passed to the `call` action are available in the `config` property of the first argument of the handler:

```js
nikita
.call({
  key: 'value',
  $handler: ({config}) => {
    // Print the config value
    console.info(config.key)
  }
})
```

## Tip

Call any registered action with `{ $handler: () => {} }` to disable its execution or, for example, test which arguments the `handler` receive. For example to know the configuration of the `execute` action:

```js
nikita
.execute({
  $handler: ({config}) => {
    console.info(config)
  }
})
```

## Style

You will probably not see a handler function defined with the `$handler` property. Instead, we define it with an alternative syntax by providing the handler function as an independent argument. The example above is commonly rewritten as:

```js
nikita
.call({
  key: 'value'
}, ({config}) => {
  // Print the config value
  console.info(config.key)
})
```

## Returned output

The value returned by the handler is a value set to the [action output](/current/api/output/). It can be of any type.

Some plugins may alter its content:

- a **boolean**, it is interpreted as the [`$status` property](/current/api/output/status/) of the output object.
  ```js
  const assert = require('assert');
  (async () => {
    const {$status} = await nikita
    .call(() => {
      // highlight-next-line
      return true
    })
    assert.equal($status, true)
  })()
  ```

- `undefined` or `void`, it is interpreted as the [`$status` property](/current/api/output/status/) of the output object.
  ```js
  const assert = require('assert');
  (async () => {
    const {$status} = await nikita
    .call(() => {
      // highlight-next-line
      return undefined
    })
    assert.equal($status, false)
  })()
  ```

- an **object**, it is merged with the default action output.
  ```js
  const assert = require('assert');
  (async () => {
    const {$status, key} = await nikita
    .call(() => {
      // highlight-next-line
      return {key: 'value'}
    })
    assert.equal($status, false)
    assert.equal(key, 'value')
  })()
  ```

- `null`, a **string**, a **number** or an **array** are interpreted as-is.
  ```js
  const assert = require('assert');
  (async () => {
    const output = await nikita
    .call(() => {
      // highlight-next-line
      return 'value'
    })
    assert.equal(output, 'value')
  })()
  ```

## Preserving output

You can use the [`raw_output` metadata](/current/api/metadata/raw_output/) to disable modifications. In such a case, the output will be the same as the returned handler:

```js
const assert = require('assert');
(async () => {
  const output = await nikita
  .call({
    // highlight-next-line
    $raw_output: true
  }, () => {
    // highlight-next-line
    return {key: 'value'}
  })
  assert.deepEqual(output, {key: 'value'})
})()
```
