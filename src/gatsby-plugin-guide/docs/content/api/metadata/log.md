---
navtitle: log
related:
- /api/tools/log/
---

# Metadata "log"

Dependending on its value, the `log` metadata disables [logging](/current/guide/logging_debugging/) in an action or call a function every time the [`tools.log`](/current/api/tools/log/) function is called.

* Type: `boolean|function`
* Default: `""`

Once defined, the `log` metadata of a parent action is propagated to all its children.

When its value is `false`, logging is disabled in the action and all its children.

When defined as a function, the function is called every time the `tools.log` function is called. The [`log`](/current/api/tools/log/#log-object), [`config`](/current/api/config/) and [`metadata`](/current/api/metadata/) properties of the action are available in the first argument of the function.


## Usage

To disable logging, pass `false` to the metadata when calling an action:

```js
nikita
// Disable logging in an action and all its children
.call({
  // highlight-next-line
  $log: false,
}, function() {
  // Call a child action without logging
  this.execute('whoami')
})
```

To be notified when logs are emitted by `tools.log`, associate a function to the `log` metadata:

```js
nikita
// Call an action
.call({
  // Declare a function
  // highlight-range{1-6}
  $log: ({log, config, metadata}) => {
    // Print properties
    console.info('log', log)
    console.info('config', config)
    console.info('metadata', metadata)
  }
}, ({tools}) => {
  // Emmit a log object
  tools.log('My log message')
})
```
