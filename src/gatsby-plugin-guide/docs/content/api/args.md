---
sort: 4
---

# Arguments

Nikita stores the original arguments passed on an action call. They are accessible inside the [action handler](/current/api/handler/) in the `args` property as an array with the preserved order:

```js
nikita
// Call an action
.call({
  my_config: 'my value'
}, ({args}) => {
  // Access to the original arguments
  console.info(args[0]) // { my_config: 'my value' }
  console.info(typeof args[1]) // function
})
```
