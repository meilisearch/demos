---
navtitle: disabled
---

# Metadata "disabled"

The `disabled` metadata property disables the execution of the current action and consequently the execution of its child actions.

* Type: `boolean`
* Default: `false`

## Usage

The behavior is activated by setting a value `true` to the `disabled` metadata property:

```js
nikita
// Call a disabled action
.call({
  // highlight-next-line
  $disabled: true
}, () => {
  // This will not be called
  console.log('I am not printed.')
})
```
