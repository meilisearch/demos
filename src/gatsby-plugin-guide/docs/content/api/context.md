---
navtitle: Context
---

# Context

When [action handlers](/current/api/handler/) are defined as [traditional function expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/function), they are executed with an action context. This context is useful to call child actions. [Array function expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions) does not have their own binding. They share the parent scope. It is impossible to call them with the action context. For this reason, the context is passed as a property named `context` in the first argument of the handler.

## Usage

To call a child action inside the handler using an arrow function, the `context` property is used:

```js
nikita
// Call a parent action using arrow function
.call(({context}) => {
  // Call a child action
  context.call(() => true)
})
```

Alternatively, with the [traditional function expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/function), the `this` scope can be used:

```js
nikita
// Handler with the tradional function expression and `this`
.call(function() {
  // Call a child action
  this.call(() => {
    // Handler implementation
  })
})
```
