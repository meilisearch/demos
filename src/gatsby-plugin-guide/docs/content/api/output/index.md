---
navtitle: Output
sort: 3
---

# Action output

The action output is the value returned by the [action handler](/current/api/handler/) and available inside a [promise](/current/guide/promise/).

## Usage

The action output is returned when its [promise](/current/guide/promise/) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await).

```js
nikita
// highlight-next-line
.call(async function() {
  // Access the action output
  // highlight-next-line
  const {who} = await this.call(({tools: {log}}) => {
    return {who: 'Nikita'}
  })
  // Print the output
  console.info(who)
  // Outputs the value "Nikita"
})
```

## Plugin enrichment

This returned value is eventually modified by plugins.

The `@nikitajs/core/lib/plugins/output/status` plugin enriches the value with the `$status` property when an object literal is returned and converts the value `true` to `{ $status: true }` when a boolean value is returned. The `@nikitajs/core/lib/plugins/output/logs` plugin returns the [logs emitted](/current/api/tools/log/) inside the action handler.

Below is the description of those properties when the returned value is an object literal:

- [`$status`](/current/api/output/status/)   
  A boolean value of the action status.
- [`$logs`](/current/api/output/logs/)   
  An array of objects with [logging](/current/guide/logging_debugging/) information of the action execution.

In case the returned value shall be preserved and untouched, the [`raw_output` metadata](/current/api/metadata/raw_output/) instructs Nikita to not alter the value returned by the handler.
