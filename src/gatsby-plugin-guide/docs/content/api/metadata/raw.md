---
navtitle: raw
related:
- /api/metadata/raw_input/
- /api/metadata/raw_output/
---

# Metadata "raw"

The `raw` metadata property is an alias to define both the [`raw_input`](/current/api/metadata/raw_input/) and the [`raw_output`](/current/api/metadata/raw_output/) metadata properties.

* Type: `boolean`
* Default: `false`

## Usage

The following example registers an action with `raw` enabled. It kind of behave just like a native JavaScript function if not the arguments which are destructured differently with `args`:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    raw: true
  },
  // Note, all options are optional
  handler: async function({args: [options={}, command='id -un']}) {
    let {stdout: who} = await this.execute(command, {trim: true})
    if (options.upper){
      who = who.toUpperCase() 
    }
    // Returned value
    return {who: who}
}})
.call(async function() {
  // Call the action with config
  // highlight-next-line
  const output = await this.my_action({upper: true}, 'whoami')
  console.info(output)
  // Print something like `{who: "NIKITA"}`
})
```

For the sake of comparaison, the same code replacing `raw` with `raw_input` returns: 

```
{ who: 'NIKITA', $status: true, $logs: [] }
```
