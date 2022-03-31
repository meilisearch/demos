---
navtitle: raw_output
related:
- /api/metadata/raw/
- /api/metadata/raw_input/
---

# Metadata "raw_output"

The `raw_output` metadata preserves the value returned by an action from modifications. Thus, the value returned inside the [action handler](/current/api/handler/) is not altered.

* Type: `boolean`
* Default: `false`

For example, an object literal returned by the handler is not enriched with the `$status` and `$log` properties as it is by [default](/current/api/handler/#return):

```js
nikita
.call(async function() {
  // Get the output
  const output = await this.call({
    // highlight-next-line
    $raw_output: true
  }, function() {
    return {who: 'Nikita'}
  })
  console.log(output)
  // Print the output `{who: 'Nikita'}`
})
```
