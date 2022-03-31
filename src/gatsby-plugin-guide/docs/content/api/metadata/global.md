---
navtitle: global
---

# Metadata "global"

The `global` metadata provides a solution to share [configuration properties](/current/api/config/) between a group of actions. For example, database actions may share the same database name and connection information, or Docker actions share information on how to connect to the Docker daemon.

* Type: `string`

## Usage

Global properties are inherited from the [parent actions](/current/api/parent/), for example:

```js
nikita
// Call a parent action with global config
.call({
  my_global: {
    my_key: 'my value'
  },
}, function() {
  // Call a child action with global metadata
  this.call({
    // highlight-next-line
    $global: 'my_global'
  }, function({config}) {
    // Print config
    console.log(config) // { my_key: 'my value' }
  })
})
```
