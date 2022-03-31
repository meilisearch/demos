---
navtitle: logs
related:
- /api/tools/log/
- /api/tools/events/
- /api/metadata/log/
- /guide/logging_debugging/
---

# Output "$logs"

Nikita stores the [log objects](/current/api/tools/log/) emitted by the [action handler](/current/api/handler/). They are available in the `$logs` property of the [action output](/current/api/output/) as an array of JavaScript objects.

It contains useful information used for debugging and introspection.

## Usage

The `$logs` array is returned when the [action Promise](/current/guide/promise/) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await):

```js
(async () => {
  // Access $logs
  const {$logs} = await nikita.execute('whoami')
  // Print $logs
  console.info($logs)
})()
```
