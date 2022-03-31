---
sort: 4
---

# Metadata

Metadata is a plain JavaScript object with properties used to contextualize or modify the execution of an action. The metadata properties are common to all Nikita actions.

## Usage

Using metadata is as easy as passing one or multiple properties prefixed with `$` when calling an action:

```js
nikita
// Call an action with the `header` and `debug` metadata
.execute({
  // highlight-range{1-2}
  $header: 'Check user',
  $debug: true,
  command: 'whoami'
})
```

Alternatively, multiple metadata properties are passed inside the `$$` object without the `$` prefix:

```js
nikita
// Call an action with the `header` and `debug` metadata
.execute({
  // highlight-range{1-4}
  $$: {
    header: 'Check user',
    debug: true,
  },
  command: 'whoami'
})
```

The metadata values are available inside the [action handler](/current/api/handler/) under the `metadata` property of the first argument:

```js
nikita
// Call an action
.call(({metadata}) => {
  // Print metadata
  console.info(metadata)
})
```

## Available metadata properties

* [`argument`](/current/api/metadata/argument/) (boolean|number|string|null, read-only)   
  Extracts the last argument which is not an object literal, interpreted as a configuration, nor a function, interpreted as a handler, nor an array, converted to multiple actions.
* [`argument_to_config`](/current/api/metadata/argument_to_config/) (string)   
  Maps a string argument passed to the action call to a configuration property with a given name.
* [`attempt`](/current/api/metadata/attempt/) (number, read-only, 0)   
  Indicates the number of times an action has been rescheduled for execution when an error occurred.
* [`debug`](/current/api/metadata/debug/) (boolean, false)   
  Prints detailed logs to the standard error output (`stderr`)
* [`depth`](/current/api/metadata/depth/) (number, read-only)   
  Indicates the level number of the action in the Nikita session tree.
* [`disabled`](/current/api/metadata/disabled/) (boolean, false)   
  Disables the execution of the action and consequently the execution of its child actions.
* [`global`](/current/api/metadata/global/) (string)   
  Provides a solution to share configuration properties between a group of actions.
* [`header`](/current/api/metadata/header/) (boolean, false)   
  Title of an actions or of a group of actions.
* [`index`](/current/api/metadata/index/) (number, read-only)   
  Indicates the index of an action relative to its sibling actions in the Nikita session tree.
* [`log`](/current/api/metadata/log/) (boolean|function)   
  Dependending on its value, disables logging in an action or call a function every time the `tools.log` function is called.
* [`module`](/current/api/metadata/module/) (string, read-only)   
  Identifies the location of the Node.js module defining the action.
* [`namespace`](/current/api/metadata/namespace/) (array, read-only)   
  Identifies the Nikita action by the name in the form of a list of addressable properties in the order it was registered.
* [`position`](/current/api/metadata/position/) (array, read-only)   
  Indicates the position of the action relative to its parent and sibling action. It is unique to each action.
* [`raw`](/current/api/metadata/raw/) (boolean, false)   
  An alias to define both the `raw_input` and the `raw_output` metadata properties.
* [`raw_input`](/current/api/metadata/raw_input/) (boolean, false)   
  Enables preventing arguments passed to an action to move into the 'config' property. It is only used when registering an action and shall be considered as an advanced usage.
* [`raw_output`](/current/api/metadata/raw_output/) (boolean, false)   
  Preserves the value returned by an action from modifications. Thus, the value returned inside the action handler is not altered.
* [`relax`](/current/api/metadata/relax/) (boolean|string|array|regexp, false)   
  Makes an action tolerant to internal errors. It returns an error instead of throwing it.
* [`retry`](/current/api/metadata/retry/) (number|boolean, 1)   
  Provides control over how many times an action is re-scheduled on error before it is finally treated as a failure.
* [`shy`](/current/api/metadata/shy/) (boolean, false)   
  Disables modification of the parent action status depending on the child action status where `shy` is activated.
* [`sleep`](/current/api/metadata/sleep/) (number, 3000)   
  Indicates the time lapse when a failed action is rescheduled. It only affects if the `retry` metadata is set to a value greater than `1` and when the action failed and is rescheduled.
* [`sudo`](/metadata/api/metadata/sudo/) (boolean)   
  Escalates the rights of the current user with `root` privileges. Passwordless sudo for the user must be enabled.
* [`templated`](/current/api/metadata/templated/) (boolean)   
  Enables or disables templating in configuration properties.
* [`time_end`](/current/api/metadata/time_end/) (number, read-only)   
  Stores the Unix timestamp at the time when the action finishes its execution.
* [`time_start`](/current/api/metadata/time_start/) (number, read-only)   
  Stores the Unix timestamp at the time when the action is executed.
* [`uuid`](/current/api/metadata/uuid/) (string, read-only)   
  Identifies a Nikita session. It is shared between all the child actions and contains a universally unique identifier (UUID) value in the RFC4122 format.
