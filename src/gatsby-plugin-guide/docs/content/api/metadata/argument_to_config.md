---
navtitle: argument_to_config
related:
- /api/metadata/argument/
---

# Metadata "argument_to_config"

The `argument_to_config` metadata property maps an argument passed to the action to a [configuration property](/current/api/config/) with the given name.

Important, the argument must not be a function nor an object literal. Functions are already interpreted as handlers and object literals as action properties. When multiple arguments are provided, only the last one is extracted.

* Type: `string`


When [writing and registering](/current/guide/register/) Nikita's actions, it is sometimes interesting to simplify how arguments are provided. Instead of passing an object literal with a configuration property inside it as a string, it is potentially more convenient to directly provide this property.

For example, the `file.touch` action accept a `target` configuration property. An example to use it is:

```js
nikita.file.touch({target: 'some/file'})
```

Alternatively, thanks to the `argument_to_config` metadata, it is possible to simplify its execution with:

```js
nikita.file.touch('some/file')
```

Note, when the same configuration property is provided to the action call, it doesn't overwrite it.

## Usage

It is simplified using the `argument_to_config` metadata. The example below define two configuration properties `key_1` and `key_2` where:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    argument_to_config: 'key_2'
  },
  handler: ({config}) => {
    // key_2 is available in config
    console.info(config)
    // Handler implementation...
  }
})
// Passing `key_2` in the configuration object 
.my_action({key_1: 'value 1', key_2: 'value 2'})
// Is similar to passing `key_2` as a string argument
.my_action({key_1: 'value 1'}, 'value 2')
// Both calls print:
// { key_1: 'value 1', key_2: 'value 2' }
```

## Manual alternative

The manual implementation of this functionality implies adding to the [action handler](/current/api/handler/) a few lines of code:

```js
nikita
// Register an action
.registry.register('my_action', ({metadata, config}) => {
  // Map argument to config
  // highlight-range{1-3}
  if (metadata.argument != null)
    if (config.my_key == null) // Don't overwrite config
      config.my_key = metadata.argument
  // Now, my_key is available in config
  console.info(config.my_key)
  // Handler implementation...
})
```
