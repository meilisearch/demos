---
navtitle: index
related:
- /api/metadata/position/
- /api/metadata/depth/
---

# Metadata "index"

The `index` metadata indicates the index of an action relative to its sibling actions in the Nikita session tree.

* Type: `number`
* Read-only

## Usage

Its value is accessed inside the [action handler](/current/api/handler/) as the `metadata.index` property.

```js
nikita
// Call an action
.call(function({metadata: {index}}) {
  console.info(index)
  // Print the value `0`
})
```
