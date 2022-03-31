---
navtitle: depth
related:
- /api/metadata/position/
- /api/metadata/index/
---

# Metadata "depth"

The `depth` metadata indicates the level number of the action in the Nikita session tree.

* Type: `number`
* Read-only

## Usage

The `depth` value is accessed inside the [action handler](/current/api/handler/):

```js
// Root action, level 0
nikita
// Parent action, level 1
.call(function() {
  // Child action, level 2
  this.call(function({metadata: {depth}}) {
    console.info(depth)
    // Print the value `2`
  })
})
```
