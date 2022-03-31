---
navtitle: sudo
---

# Metadata "sudo"

The `sudo` metadata escalates the rights of the current user with `root` privileges. Passwordless sudo for the user must be enabled.

* Type: `boolean`

## Usage

The `sudo` metadata is propagated to all child actions. To run an action with `root` privileges, pass `true` to the metadata:

```js
nikita
// Enable sudo to all child actions
.call({
  // highlight-next-line
  $sudo: true,
}, async function() {
  // Get current user
  const {stdout} = await this.execute({
    command: 'whoami'
  })
  // Print current user
  console.log(stdout) // root
})
```
