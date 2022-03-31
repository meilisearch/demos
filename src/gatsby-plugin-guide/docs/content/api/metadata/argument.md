---
navtitle: argument
related:
- /api/metadata/argument_to_config/
---

# Metadata "argument"

The `argument` metadata property extracts the last argument which is not an object literal, interpreted as a configuration, nor a function, interpreted as a handler, nor an array, converted to multiple actions.

* Type: `boolean|number|string|null`
* Read-only

This metadata is primarily used to implement the [short declaration](/current/api/config/#short-declaration) of configuration properties. The `argument_to_config` metadata property leverages and simplifies its usage. It is supported by several Nikita actions such as the [`nikita.execute`](/current/api/execute/) and [`nikita.fs.mkdir`](/current/api/fs/mkdir/) actions.

This property does not provide a complete representation of the user input. Not all arguments are provided and only the last one is interpreted. Refers to the `args` action property to access the action arguments.

## Usage

The metadata is available as `metadata.argument` inside the [action handler](/current/api/handler/):

```js
nikita.call('my value', ({metadata}) => {
  console.info(metadata.argument)
  // Print `my value`
})
```

## Recommandation

When [writing and registering](/current/guide/register/) Nikita actions, the behavior is similar. When an action make use of `argument`, it is usually a good practice to handle its associated value before the handler is executed, commonly inside the `on_action` hook. This way, other plugins can honors it.

For example, consider an action which make use of a `value` configuration declared in the schema definition. For the schema to validate when `value` is not provided as a configuration property but as a string argument, it must be converted before the schema plugin validate the action:

```js
const value = await nikita
// Register an action
.registry.register('ping', {
  // Register the `on_action` hook
  hooks: {
    on_action: ({config, metadata}) => {
      if(config.value === undefined){
        config.value = metadata.argument
      }
    }
  },
  // Define the configuration schema definition
  metadata: {
    definitions: {
      type: 'object',
      required: ['value']
    }
  },
  // Implement the action, it simply return `value`
  handler: ({config}) => {
    return config.value
  }
})
// Call the action with a string argument
.ping('pong')
// Print `pong`
console.info(value)
```
