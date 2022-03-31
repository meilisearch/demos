---
sort: 3
related:
- /api/output/status/
---

# Idempotence and status

In the context of software deployment, idempotence means that an action with the same parameters can be executed multiple times without changing the final state of the system. It is a fundamental concept and every action in Nikita follows this principle.

The [`$status` output](/current/api/output/status/) property is used and interpreted with different meanings but in most cases, it indicates that a change occurred. For example, when calling the `nikita.file.touch` action, the status is `true` if the file was created. However, the second call returns the status of `false`:

```js
nikita
.call(async function() {
  const path = '/tmp/nikita/a_file'
  // Remove the file to make sure it is not exist
  this.fs.remove(path)
  // Touch 1st time
  var {$status} = await this.file.touch(path)
  console.info($status)  // true
  // Touch 2nd time
  var {$status} = await this.file.touch(path)
  console.info($status)  // false
})
```
