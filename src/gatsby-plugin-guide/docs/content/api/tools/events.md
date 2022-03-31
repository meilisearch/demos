---
navtitle: events
---

# Tool "events"

Nikita provides a facility to publish and listen to events. An instance of the [Node.js EventEmitter](https://nodejs.org/api/events.html) class is exported and available under the `tools.events` property.

Events messages don't need to respect any particular structure unless you use an event name reserved internally by Nikita. No validation will occur.

Refers to the [`tools.log`](/current/api/tools/log/) function for a more sophisticated mechanism, it internally relies on `tools.events`. It provides context information to the event listener such as the module name where the event occurred, the logging level, etc.

## Usage

You can publish events by calling the `tools.events.emit(eventName[, ...args])` function and subscribe to those events by registering listeners with the `tools.events.on(eventName, listener)` function. The following example demonstrates it:

```js
nikita(({tools}) => {
  // Register a listener
  tools.events.on('whoami', (name) => {
    console.info(`I am ${name}`)
  })
  // Emit an event
  tools.events.emit('whoami', 'Nikita')
})
// Outputs with "I am Nikita"
```

## Available events

Certain events are automatically emitted. They correspond to the action lifecycle and provide notifications on the internal state of the Nikita session:

- `nikita:action:start`   
  It is emitted right before an action handler execution.
- `nikita:action:end`   
  It is emitted after the action handler has completed, whether it failed or was successful.
- `nikita:resolved`   
  It is emitted once at a Nikita session when all action handlers have completed successfully.
- `nikita:rejected`   
  It is emitted once at a Nikita session when an action handler has failed.

Some functionality like [logging and debugging](/current/guide/logging_debugging/) introduces their own events:

- `diff`   
  Content modification. It is emitted by the `file` action.
- `stderr`   
  Data string written to standard error when executing a command. It is emitted by the `nikita.execute` action to store the stderr output from the executed command.
- `stderr_stream`   
  Datastream written to standard error. It is emitted by the `nikita.execute` to listen to stderr. A message `null` is emitted to indicate that the stream is closed.
- `stdin`   
  Executed command. It is emitted by the `nikita.execute` action to share the executed command.
- `stdout`   
  Data string written to standard output when executing a command. It is emitted by the `nikita.execute` action to store the stdout output from the executed command.
- `stdout_stream`   
  Datastream written to standard output. It is emitted by the `nikita.execute` to listen to stdout. A message `null` is emitted to indicate that the stream is closed.
- `text`   
  Default event when the `tools.log()` function is called.
