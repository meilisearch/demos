---
navtitle: retry
---

# Metadata "retry"

Setting the `retry` metadata provides control over how many times an action is re-scheduled on error before it is finally treated as a failure.

* Type: `number|boolean`
* Default: `1`

It is commonly used conjointly with the [`attempt` metadata](/current/api/metadata/attempt/) which provides an indicator over how many times an action was rescheduled.

## Usage

The default value is `1` which means that actions are not rescheduled on error.

If provided as a number, the value must be superior or equal to `1`. For example, the value `3` means the action will be executed a maximum of 3 times. If the third time the action fails, then it will be treated by the Nikita session as a failed action.

```js
const assert = require('assert');
nikita
// Call an action
.call({
  // highlight-next-line
  $retry: 3
}, ({metadata}) => {
  // First 2 attempts failed with an assertion error,
  // but the 3rd one succeeded
  assert.equal(metadata.attempt, 2)
})
```

### Boolean value

Setting the value as `true` causes unlimited number of retries:

```js
const assert = require('assert');
nikita
// Call an action
.call({
  // highlight-next-line
  $retry: true
}, function ({metadata}) {
  // First 9 attempts failed with an assertion error,
  // but 10th attempt succeeded
  assert.equal(metadata.attempt, 9)
})
```

The value `false` is the same as `1`.

## With the `relax` metadata

When used with the [`relax` metadata](/current/api/metadata/relax/), every attempt will be rescheduled. Said differently, marking an action as relax will not prevent the action to be re-executed on error.

```js
const assert = require('assert');
(async () => {
  var {$status} = await nikita
  // Call an action
  .call({
    // highlight-range{1-2}
    $retry: 2,
    $relax: true
  }, () => {
    // Will fail 2 times
    throw Error('Oups')
  })
  // Will be executed because the action was not fatal
  assert.equal($status, false)
})()
```
