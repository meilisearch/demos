---
navtitle: log
related:
- /api/tools/events/
- /api/output/log/
- /api/metadata/log/
---

# Tool "log"

The `log` tool is a function to publish information about the state of Nikita's actions.

It is possible to listen to the emitted log objects and to use their information for [logging or debugging](/current/guide/logging_debugging/). The [`log.cli`](/current/actions/log/cli/) action prints the status of the Nikita session to the console. The [`log.md`](/current/actions/log/md/) action dumps the logs into a file using the [Markdown](https://en.wikipedia.org/wiki/Markdown) format.

Emitted log objects are also available in the [`$logs` array](/current/api/output/logs/) returned in the [action output](/current/api/output/).

The `log` function relies internally on the [Node.js events](https://nodejs.org/api/events.html) module and it uses the [`tools.events.emit`](/current/api/tools/events/) function.

## Usage

It is available inside the [action handler](/current/api/handler/) as the `tools.log` property of the first argument.

To emit an event, call the `tools.log` function passing properties to the argument object:

```js
nikita
// Call an action
.call(({tools}) => {
// Emit an event
tools.log({
  level: 'DEBUG',
  message: 'Some message'
})
})
```

To pass only the `message` property, call it with a string argument:

```js
nikita
// Call an action
.call(({tools}) => {
// Emit an event
tools.log('Some message')
})
```

## Log object

The log object contains the information about the state of an action and consist of the following properties:

- `depth`   
  The depth level of the action in the Nikita session tree. See the [`depth` metadata](/current/api/metadata/depth/) for complementary information.
- `index`   
  The index position of the action relative to its siblings. See the [`index` metadata](/current/api/metadata/index/) for complementary information.
- `filename`   
  The full path to the file where the event is emitted.
- `file`   
  The filename where the event is emitted.
- `level`   
  The log level, default is `INFO`. Suggested values are `DEBUG`, `INFO`, `WARN`, `ERROR`.
- `line`   
  The line number where the event is emitted.
- `message`   
  The user message.
- `module`   
  The path to the Node.js module of the registered action honored from the [`module` metadata](/current/api/metadata/module/).
- `namespace`   
  The list of names of the action from root to a child. It is honored from the [`module` metadata](/current/api/metadata/module/).
- `position`   
  The list of indices corresponding to the position in the hierarchical tree of the Nikita session. See the [`position` metadata](/current/api/metadata/position/) for complementary information.
- `time`   
  The Unix timestamp of the date when the event is emitted.
- `type`   
  The [Node.js event](https://nodejs.org/api/events.html) name, default to `text`. See the [`events` tool](/current/api/tools/events/) for a list of supported event types.
