---
navtitle: namespace
related:
- /api/metadata/module/
---

# Metadata "namespace"

The `namespace` metadata identifies the Nikita action by the name in the form of a list of addressable properties in the order it was [registered](/current/guide/registry/).

* Type: `array`
* Read-only

For example, the action registered by the `["my", "action"]` array is accessible with `nikita.my.action`.

```js
// Import the registry module
const registry = require('@nikitajs/core/lib/registry');
// Register an action
registry.register(['my', 'action'], ({metadata: {namespace}}) => {
  // Handler implementation
  console.info(namespace) // [ 'my', 'action' ]
})
// Call the action
nikita.my.action()
```
