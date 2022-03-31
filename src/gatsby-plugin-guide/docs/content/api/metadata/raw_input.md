---
navtitle: raw_input
related:
- /api/metadata/raw/
- /api/metadata/raw_output/
---

# Metadata "raw_input"

The `raw_input` metadata enables preventing arguments passed to an action to move into the ['config' property](/current/api/config/). It is only used when [registering an action](/current/guide/registry/) and shall be considered as an advanced usage.

* Type: `boolean`
* Default: `false`

## Usage

The `raw_input` metadata property is commonly used along the `args` property of the action:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    raw_input: true
  },
  handler: function({config, args}){
    console.info(args)
    // Print `[ { who: 'Nikita' }, 'whoami' ]`
  }
})
// Call the action
.my_action({who: 'Nikita'}, 'whoami')
```

## Notes about configuration

The `config` property is empty when passing arguments to the action with the metadata enabled:

```js
nikita
// Register an action
.registry.register('my_action', {
  // highlight-next-line
  metadata: {
    raw_input: true
  },
  handler: function({config}){
    console.info(config)
    // Print config as `{}`
  }
})
// Call the action
.my_action({who: 'Nikita'})
```
