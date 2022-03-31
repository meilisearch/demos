---
navtitle: dirty
related:
- /api/metadata/tmpdir/
---

# Metadata "dirty"

The `dirty` metadata disables decommissioning a [temporary directory](/current/api/metadata/tmpdir/) after action execution.

* Type: `boolean`

## Usage

Pass `true` to the metadata to disable decommissioning:

```js
(async () => {
  await nikita
  // Call an action with $tmpdir and $dirty
  .call({
    // highlight-range{1-2}
    $dirty: true,
    $tmpdir: '/tmp/a_dir'
  }, () => true)
  // Assert the temporary directory exists
  .fs.assert('/tmp/a_dir')
})()
```
