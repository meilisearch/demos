---
sort: 8
---

# Error handling

Nikita rejects errors when they occur. Remember, [an action always returns a promise](/current/guide/promise/) and there are multiple ways of handling errors with promises.

By default, errors are not managed by Nikita. It is your responsibility to handle errors and alter the flow of execution.

## Using `try/catch` blocks with `async/await`

The most common method to catch errors is using the [`try/catch` statement](https://nodejs.org/en/knowledge/errors/what-is-try-catch/) in a combination with the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await). It is a question of tastes but some consider it to be the most elegant:

```js
// Global Nikita session
nikita
// Call an action with asynchronous handler
// highlight-range{1-9}
.call(async function() {
  try {
    // Action throws an error
    await this.call(() => {
      throw Error('Catch me!')
    })
  } catch(err) {
    console.info(err.message) // Catch me!
  }
  // 2nd action is called
  this.call(() => {
    console.info('I am printed.')
  })
})
```

## Using the Promise API

Alternatively, this example can be rewritten using the Promise API methods. The following example uses the [`catch` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/catch) to declare the rejection handler and the [`finally` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally) to continue the session:

```js
// Global Nikita session
nikita
.call(function() {
  // Action rejects an error
  this.call(function() {
    throw Error('Catch me!')
  })
  // Catch and handle an error
  // highlight-range{1-3}
  .catch((err) => {
    console.info(err.message) // Catch me! 
  })
  // Run next commands
  // highlight-range{1-6}
  .finally(() => {
    // 2nd action is called
    this.call(() => {
      console.info('I am printed.')
    })
  })
})
```

Alternatively, the errors is caught with the [`then` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then) when providing the rejection handler as the second argument:

```js
// Global Nikita session
nikita
.call(function() {
  // Action rejects an error
  this.call(function() {
    throw Error('Catch me!')
  })
  // Catch and handle an error
  // highlight-range{1-6}
  .then(
    (result) => {
      console.info(result) // Run when fulfilled
    },
    (err) => {
      console.info(err.message) // Run when rejected 
    }
  )
  // Run next commands
  .finally(() => {
    // 2nd action is called
    this.call(() => {
      console.info('I am printed.')
    })
  })
})
```

## Cascading errors

By returning the action promise, errors are cascaded from child actions to the parent:

```js
nikita
// Call parent action
.call(function() {
  // Call child action
  return this.call(() => {
    throw Error('Catch me!')
  })
})
// Catch error of the child action
.catch((err) => {
  console.info(err.message) // Catch me!
})
```

## Relax behavior

To disable the session interruption in case of failure of an action and to treat an error as non-destructive, you can use the [`relax` metadata](/current/api/metadata/relax/). In such a case, the error object will be available as a property in the [action output](/current/api/output/). 

```js
nikita
.call(async function() {
  // Get error message of the 1st action
  const {error} = await this.call(({
    // Enable relax behavior
    // highlight-next-line
    $relax: true
  }), () => {
    throw Error('I am error!')
  })
  // Print error message
  console.info(error.message)  // I am error!
  // 2nd action is called
  await this.call(() => {
    console.info('I am printed.')
  })
})
```

## Action arguments as an array

When an action is called with an array, it is executed for each element of the array. In such case, the execution flow is managed by Nikita. Actions are called sequentially and the flow is interrupted with the first action to reject an Error:

```js
try {
  await nikita.call([
    () => 'Handler called',
    () => throw 'KO',
    () => 'Handler not called',
  ])
} catch(err) {
  assert(err.message === 'KO')
}
```

## Scheduler behavior

TODO, not yet implemented: we will provide a way for the scheduler to manage errors, in such case, subsequent actions will not be executed despite having `try...catch` user handling.

In case of any action fails and an error is not caught, the native Nikita scheduler interrupts the global Nikita session and subsequent actions are not performed. For example, the second action is never being called because the first one fails:

```js
// Global Nikita session
nikita
.call(function() {
  // 1st action fails
  this.call(() => {
    // highlight-next-line
    throw Error('Catch me!')
  })
  // 2nd action is not called
  this.call(() => {
    console.info('I will be printed.')
  })
})
```
