---
navtitle: sleep
---

# Metadata "sleep"

The `sleep` metadata indicates the time lapse when a failed action is rescheduled. It only affects if the [`retry` metadata](/current/api/metadata/retry/) is set to a value greater than `1` and when the action failed and is rescheduled.

* Type: `number`
* Default: `3000`

## Usage

The `sleep` value is an integer and is interpreted in a millisecond. The default value is `3000`. Here is an example raising the sleep period to 5 seconds.

```js
const assert = require('assert');
nikita
.call({
  // highlight-range{1-2}
  $retry: 3,
  $sleep: 5000
}, ({metadata}) => {
  // First 2 attempts fail with an assertion error,
  // the 3rd attempt succeeds in about 10 seconds
  assert.equal(metadata.attempt, 2)
})
```

Any value not superior or equal to zero will generate an error.

### Global value

While you can set this metadata on selected actions, it is safe to declare it at the session level. In such a case, it will act as the default value and can still be overwritten on a per-action basis.

```js
const assert = require('assert');
nikita({
  // highlight-next-line
  $sleep: 5000
})
// Use the global sleep value of 5s
.call({
  // highlight-next-line
  $retry: 3
}, ({metadata}) => {
  assert.equal(metadata.attempt, 2)
})
// Overwrite the global value of 5s and use 1s
.call({
  // highlight-range{1-2}
  $retry: 3,
  $sleep: 1000
}, ({metadata}) => {
  assert.equal(metadata.attempt, 2)
})
```
