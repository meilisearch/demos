---
navtitle: shy
---

# Metadata "shy"

The `shy` metadata disables modification of the parent action [status](/current/guide/status/) depending on the child action status where `shy` is activated.

* Type: `boolean`
* Default: `false`

By default, the status of an action will be `true` if at least one of the child actions has a status of `true`. 

Sometimes, some child actions are not relevant to indicate a change of the parent action status. There are multiple reasons for this. For example, a child action has no impact, like checking prerequisites, or the change of the parent status is assumed by another sibling action.

## Usage

The `shy` metadata is a boolean. The value is `false` by default. Set the value to `true` if you wish to activate the metadata.

```js
const assert = require('assert');
(async () => {
  var {$status} = await nikita
  .call(async function() {
    var {$status} = await this.execute({
      // highlight-next-line
      $shy: true,
      command: 'exit 0'
    })
    // Status of the child
    assert.equal($status, true)
  })
  // Status of the parent is not affected by the child
  assert.equal($status, false)
})()
```

### Status in the action output

The action output contains the status of the execution no matter if the `shy` metadata is activated or not.

```js
const assert = require('assert');
(async () => {
  // Status is set when shy is deactivated (default behavior)
  var {$status} = await nikita
  .execute({
    // highlight-next-line
    $shy: false,
    command: 'exit 0'
  })
  assert.equal($status, true)
  // Status is set when shy is activated
  var {$status} = await nikita
  .call({
    // highlight-next-line
    $shy: true,
    command: 'exit 0'
  })
  assert.equal($status, true)
})()
```
