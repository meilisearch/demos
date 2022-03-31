---
navtitle: status
related:
- /guide/idempotence/
---

# Output "$status"

The status output indicates whether an action had any impact. It is a core concept shared by all Nikita actions. It is also used by actions to implement [idempotence](/current/guide/idempotence/).

It is a boolean value returned to the [action output](/current/api/output/) as the `$status` property.

The status meaning differs from one action to another, here are a few examples:

- *Touching a file*   
  The status is `true` if the file was created or any metadata associated with the file has changed, such as the timestamp modification or a change of ownership.
- *Modification of a configuration file (JSON, YAML, INI...)*   
  The status is `true` if a property or any metadata associated with the file has changed. A change of format, like prettifying the source code, will not affect the status, while the addition of a new property or the modification on the value of existing property will set the status to `true`.
- *Checking if a port is open*   
  The status is set to `true` if a server is listening on that port and `false` otherwise. This is arguably an alternative usage. In such a case, it is often used conjointly with the [`shy` metadata](/current/api/metadata/shy/) to ensure that parent actions don't get their status modified.

## Usage

The `$status` value is returned when the [action Promise](/current/guide/promise/) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await):

```js
(async () => {
  const {$status} = await nikita.file.touch('/tmp/nikita/a_file')
  // Print status
  console.info($status)
})()
```

## Changing the status value

By default, Nikita's actions return the status value of `false`. It can be changed by the [action handler](/current/api/handler/) or the child actions. 

The handler modifies the status when it returns a boolean value or an object with the `$status` property:

```js
nikita
.call(async function(){
  // Default value
  var {$status} = await this.call(() => {
    return
  })
  console.info($status)  // false
  // Return boolean
  var {$status} = await this.call(() => true)
  console.info($status)  // true
  // Return object
  var {$status} = await this.call(() => {
    return {
      $status: true
    }
  })
  console.info($status)  // true
})
```

When the [action handler](/current/api/handler/) is made of multiple child actions, the status is `true` if at least one of the child actions has a status of `true`:

```js
(async () => {
  var {$status} = await nikita
  // Parent action
  .call(async function() {
    // Child action, returns `false`
    this.call(() => false)
    // Child action, returns `true`
    this.call(() => true)
  })
  console.info($status)  // true
})()
```
