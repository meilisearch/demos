---
navtitle: Config
sort: 1
---

# Configuration properties

Configuration properties are used to contextualize the [action handler](/current/api/handler/) and they are specific to every action.

## Usage

They are commonly provided as an object when calling an action. For example, the [`nikita.execute`](/current/actions/core/execute/) defines a `command` configuration property which is provided as:

```js
nikita
  // Pass an object with the "command" configuration property
  .execute({ command: "whoami" });
```

The action handler receives the configuration properties in the `config` property of the first argument:

```js
nikita
  // Call an action with a configuration property and a custom handler
  .call({ key: "value" }, ({ config }) => {
    // Configuration properties are passed to the handler
    // Print the config value
    console.info(config.key);
  });
```

## Short declaration

Some actions can also receive the configuration property as a string. For example, the following declaration of the `nikita.execute` action achieves the same result as at the example above:

```js
nikita
  // Pass the command as a string
  .execute("whoami");
```

The string configuration is here for convenience. Internally, the handler of the `nikita.execute` action receives the configuration as an object and search for the [`argument` metadata](/current/api/metadata/argument/) property. Here's an example of how it can be implemented into an action:

```js
nikita// Register the action
.registry
  .register("my_action", ({ config, metadata }) => {
    // Define the "key" configuration property
    if (metadata.argument != null) config.key = metadata.argument;
    // More code goes here
  });
```

To make it more generic, Nikita provides the [`argument_to_config` metadata](/current/api/metadata/argument_to_config/) property which maps an argument into a configuration property with the desired name.

## Merging properties

When multiple configuration properties are passed, they are merged. The last keys take precedence over previously defined keys. The example below asserts this behavior:

```js
const assert = require("assert");
(async () => {
  await nikita
    // highlight-range{1-3}
    .call({ key: "old value" }, { key: "new value" }, ({ config }) => {
      assert.equal(config.key, "new value");
    });
})();
```

Note, the values set as `undefined` will not overwrite previously defined properties:

```js
const assert = require("assert");
(async () => {
  await nikita
    // highlight-range{1-3}
    .call({ key: "old value" }, { key: undefined }, ({ config }) => {
      assert.equal(config.key, "old value");
    });
})();
```
