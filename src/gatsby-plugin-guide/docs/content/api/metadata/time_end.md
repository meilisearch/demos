---
navtitle: time_end
related:
- /api/metadata/time_start/
- /api/sibling/
---

# Metadata "time_end"

The `time_end` metadata property stores the Unix timestamp at the time when the action finishes its execution.

* Type: `number`
* Read-only

The value does not yet exists when the handler function is executed. It is however accessible inside the [action handler](/current/api/handler/) of the next [sibling](/current/api/sibling/)  action:

```js
nikita
// Call 1st action
.call(({metadata}) => {
  console.log(metadata.time_end) // undefined
})
// Call 2nd action
.call(({sibling}) => {
  // Print time_end of the sibling action
  console.info(sibling.metadata.time_end) // 1614765071544
})
```

## Introspection

You can traverse previously executed actions and print the execution time by substracting the `time_start` to `time_end` metadata properties. An example with the `tools.dig` action utility is:

```js
nikita(function(){
  this.call(function(){
    this.call(function(){
      return new Promise((resolve) => {
        setTimeout(resolve, 100) // Wait a bit
      })
    })
    this.call(function(){
      return new Promise((resolve) => {
        setTimeout(resolve, 100) // Wait a bit
      })
    })
  })
  this.call(function({tools: {dig}}){
    // Note, `dig` traverse the session history
    // starting with the most recent action
    dig( ({metadata: {position, time_end, time_start}}) =>
      time_end &&
      console.log(
        `Action ${position.join('.')} tooks ${time_end - time_start}ms`
      )
    )
    // Print something like
    // Action 0.0.1 tooks 102ms
    // Action 0.0.0 tooks 107ms
    // Action 0.0 tooks 214ms
  })
})
```

The various log-related actions use this information to report the action execution time.
