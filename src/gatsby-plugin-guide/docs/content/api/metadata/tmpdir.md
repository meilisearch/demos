---
navtitle: tmpdir
related:
- /api/metadata/dirty/
---

# Metadata "tmpdir"

The `tmpdir` metadata creates a temporary directory for the duration of the action execution.  The directory is decommissioned right before the action finishes its execution unless the [`dirty` metadata](/current/api/metadata/dirty/) is enabled.

* Type: `boolean|string|function`

## Usage

To create a temporary directory pass `true` to the metadata. The pathname of the created directory is available inside the [action handler](/current/api/handler/):

```js
nikita
// Call an action with $tmpdir
.call({
  // highlight-next-line
  $tmpdir: true
}, ({metadata: {tmpdir}}) => {
  // Print pathname
  console.info(tmpdir) // /var/folders/by/fbqj_yjx30xgx_4tc0fr50q80000gn/T/nikita-005a47fc-0d7d-49c2-9411-c4989e6c16f3
})
```

When actions are [running over SSH](/current/guide/local_remote/), the temporary directory is always created inside the `/tmp` folder. Otherwise, it is inside the default OS temporary directory returned by the Node.js native function [`os.tmpdir()`](https://nodejs.org/api/os.html#os_os_tmpdir).

The directory name is generated basing on the [`uuid` metadata](/current/api/metadata/uuid/). When it is created with boolean `true`, the directory is unique for the entire Nikita's session and shared between all child actions. Thus, enabling the metadata in children doesn't make sense when it is already enabled in the parent action. The following example asserts this behavior:

```js
const assert = require('assert');
(async ()=>{
  await nikita
  // Call parent action with tmpdir enabled
  .call({
    // highlight-next-line
    $tmpdir: true
  }, async function({metadata: {tmpdir}}) {
    // Save parent tmpdir
    const parentDir = tmpdir
    // Call child action with tmpdir enabled
    await this.call({
      // highlight-next-line
      $tmpdir: true
    }, function({metadata: {tmpdir}}) {
      // Assert directories are the same
      // highlight-next-line
      assert.equal(parentDir, tmpdir)
    })
  })
})()
```

## String value

To provide a pathname to a directory being created, pass a string value. The pathname can be relative to the default OS temporary folder or absolute to the file system:

```js
nikita
// Relative pathname
.call({
  // highlight-next-line
  $tmpdir: './a_relative_dir',
}, ({metadata: {tmpdir}}) => {
  // Print pathname
  console.info(tmpdir) // /var/folders/by/fbqj_yjx30xgx_4tc0fr50q80000gn/T/a_relative_dir
})
// Absolute pathname
.call({
  // highlight-next-line
  $tmpdir: '/tmp/an_absolute_dir',
}, ({metadata: {tmpdir}}) => {
  // Print pathname
  console.info(tmpdir) // /tmp/an_absolute_dir
})
```

## Function value

To provide a custom logic on creating a directory pathname, associate a function to the `tmpdir` metadata that returns the pathname. It receives an object as the first argument with the following properties:

- `action`   
  Current action object
- `os_tmpdir`   
  Default OS temporary folder
- `tmpdir`   
  Generated directory name basing on the `uuid` metadata.
  
The following example demonstrates creating a directory basing on a [configuration property](/current/api/config/):

```js
nikita
// Relative pathname
.call({
  user: 'leon',
  // highlight-next-line
  $tmpdir: ({action, os_tmpdir, tmpdir}) => `/tmp/${action.config.user}`
}, ({metadata: {tmpdir}}) => {
  // Print pathname
  console.info(tmpdir) // /tmp/leon
})
```
