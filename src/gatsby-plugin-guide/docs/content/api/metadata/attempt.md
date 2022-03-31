---
navtitle: attempt
---

# Metadata "attempt"

The `attempt` metadata is an indicator of the number of times an action has been rescheduled for execution when an error occurred.

* Type: `number`
* Default: `0`
* Read-only

The property is meant to be used conjointly with the [`retry` metadata](/current/api/metadata/retry/) metadata. It is available in the handler function to know how many times an action is re-scheduled when an error occurred.

## Usage

The associated value is incremented after each retry starting with the value `0`. The following example will be failed on the first attempt before finally succeed on its second attempt.

```js
// Dependencies
const assert = require('assert');
(async () => {
  var {attempts} = await nikita({
    // highlight-next-line
    $retry: 2
  }, ({metadata}) => {
    if(metadata.attempt === 0){
      throw Error('Oups')
    }
    return {attempts: metadata.attempt}
  })
  // The first attempt failed with an error,
  // but the second attempt succeed
  assert.equal(attempts, 1)
})()
```
