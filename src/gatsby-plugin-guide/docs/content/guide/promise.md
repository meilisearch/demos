---
sort: 2
---

# Action Promise

Nikita's actions always return [JavaScript Promise](https://nodejs.dev/learn/understanding-javascript-promises) and provide the guarantee that all actions are executed sequentially according to their declaration.

## Accessing the action output

The [action output](/current/api/output/) is returned after its Promise is fulfilled.

The most elegant and relevant approach to access the action output is using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await). It avoids a "callback hell" in case you need to pass a result of one action to a [configuration property](/current/api/config/) of another action as in the following example:

```js
// Dependency
const assert = require('assert');
// Call anonymous asynchronous function 
(async () => {
  // Define empty array
  history = []
  // New Nikita session
  await nikita
  .call(async function() {
    // Access the action output
    const result = await this.call(() => 'first')
    // Pass result to the next action
    await this.call({
      item: result
    }, function({config}) {
      // Push the first item to the array
      history.push(config.item)
    })
  })
  // Push the second item synchronously after Nikita actions
  history.push('second')
  // Assert the order
  assert.deepEqual(history, ['first', 'second'])
})()
```

Alternatively, this example can be rewritten using the Promise API methods. To access the result, you can use the [`then` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then) and pass a callback function. You also can call the [`finally` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally) and pass a callback function with JavaScript commands to run them synchronously after the Nikita actions:

```js
// Dependency
const assert = require('assert');
// Define empty array
history = []
// New Nikita session
nikita
.call(function() {
  // Call an action
  this.call(() => 'first')
  // Access the action output
  .then((result) => {
    // Pass result to the next action
    this.call({
      item: result
    }, ({config}) => {
      // Push the first item to the array
      history.push(config.item)
    })
  })
})
.finally(() => {
  // Push the second item synchronously after Nikita actions
  history.push('second')
  // Assert the order
  assert.deepEqual(history, ['first', 'second'])
})
```

When an error occurs while executing actions, it can be caught. Read [the following documentation](/current/guide/error/) about handling errors in Nikita.
