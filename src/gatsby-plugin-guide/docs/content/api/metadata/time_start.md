---
navtitle: time_start
related:
- /api/metadata/time_end/
---

# Metadata "time_start"

The `time_start` metadata property stores the Unix timestamp at the time when the action is executed.

* Type: `number`
* Read-only

## Usage

The value is accessible inside the [action handler](/current/api/handler/).

```js
nikita
// Call an action
.call(({metadata: {time_start}}) => {
  // Print timestamp
  console.info(time_start) // 1614763528497
})
```

See the [`time_end` metadata property](/current/api/metadata/time_start/) for complementary examples.
