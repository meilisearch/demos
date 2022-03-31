---
sort: 6
---

# Logging and Debugging

Nikita provides multiple mechanisms to report, dive into the logs and intercept instructions. Most of them can be instantaneously activated and you are provided with simple building blocks to quickly write your own.

## Quick debugging

While developing, the [`debug` metadata](/current/api/metadata/debug/) can be used to get visual and detailed information in the standard output (stdout). This behavior can be propagated to the global Nikita session, to all child actions, or the specific action:

The following example demonstrates global definition:

```js
// Activate debugging to the global session
nikita({
  // highlight-next-line
  $debug: true
})
.execute({
  command: 'echo "Hello!"'
})
.execute({
  command: 'echo "It is me!"'
})
```

It outputs lines with debugging information prefixed with the level of the action in the tree of the session:

```
[1.1.INFO execute] echo "Hello!"
[1.1.INFO execute] Hello!
[1.2.INFO execute] echo "It is me!"
[1.2.INFO execute] It is me!
```

To propagate for all child actions, the metadata is defined to the specific parent: 

```js
nikita
// Activate debugging to all child actions
.call({
  // highlight-next-line
  $debug: true
}, function() {
  this.execute({
    command: 'echo "Hello!"'
  })
  this.execute({
    command: 'echo "It is me!"'
  })
})
.execute({
  command: 'echo "But not me."'
})
```

Or to the specific action in trouble:

```js
nikita
// Activate debugging to the specific action
.execute({
  // highlight-next-line
  $debug: true,
  command: 'echo "I am in trouble!"'
})
.execute({
  command: 'echo "I am not."'
})

```

## Getting started with logging

In case you wish to activate standard logging, here is a quick and easy way to get you started.

```js
nikita
// Activate CLI reporting
// highlight-next-line
.log.cli()
// Activate log information written in Markdown
// highlight-next-line
.log.md()
// Now start the real job
.execute({
  command: 'echo "Hello world!"'
})
```

It prints short messages to stdout indicating the status of the actions' execution and detailed information into a Markdown file inside the "./log" folder. This folder is created in the current working directory in case it doesn't yet exist.

## Deep dive into logging

Nikita provides a flexible architecture to intercept the information. Users can write logs to custom destinations in any format. To write your own logging actions, once you register it, you can choose among the following options:

- [Listen to events](#listening-to-events)   
  It is a flexible solution in which you listen to every [event](/current/guide/events/) emitted by Nikita. However, it requires you to fully implemented what you wish to do with the data.
- [Extending `nikita.log.stream`](#extending-nikitalogstream)   
  It is an action that simplifies the integration of a new logging appender by expecting a [Node.js writable stream](https://nodejs.org/api/stream.html#stream_writable_streams) and a serializer object.
- [Extending `nikita.log.fs`](#extending-nikitalogfs)   
  Built upon the `nikita.log.stream` action, it provides basic functionality to write information to the filesystem. You are only responsible for serializing the data. The `nikita.log.csv` and `nikita.log.md` actions are such examples.

### Listening to events

At the heart of this architecture is the [Nikita Events API](/current/guide/events/). A Nikita session extends the [native Node.js Events API](https://nodejs.org/api/events.html). All other mechanisms presented below rely on the events emitted inside the Nikita session. You may use the `on(event, handler)` function to catch the event but extending the `nikita.log.stream` action is probably a bit easier, expecting a string writer and a serializer function.

### Extending `nikita.log.stream`

It is a low-level action that is meant to be extended and not to be called directly. More specific actions could use the `nikita.log.stream` action by providing a [Node.js writable stream](https://nodejs.org/api/stream.html#stream_writable_streams) and a serializer object.

A serializer is an object which must be implemented by the user. Keys correspond to the event types and their associated value is a function that must be implemented to serialize the information.

### Extending `nikita.log.fs`

The `nikita.log.fs` action provides an easy and quick way to write your own logging actions. For example, both `nikita.log.csv` and `nikita.log.md` described below rely upon it. This way, you can leverage the [existing configuration properties](/current/actions/log/fs/#schema).

For example, below is a lightly modify version of the `nikita.log.csv` action:

```js
module.exports = {
  ssh: false,
  handler: async function({config}) {
    return this.log.fs({
      config: config,
      serializer: {
        'nikita:action:start': function(action) {
          const header = action.metadata.header ? action.metadata.header : action.metadata.position
          return `"${header}",,\n`
        },
        'text': function(log){
          return `${log.type},${log.level},${JSON.stringify(log.message)}\n`
        },
      }
    })
  }
}
```

## CLI reporting

The CLI reporting is built on top of the log events. It prints pretty and colorful information to the stdout of the terminal. In case no [TTY](https://en.wikipedia.org/wiki/Tty_(unix)) is detected, no color formatting will be written by default unless the `color` configuration property is `true` or made of an object.

The action only reports if the [`header` metadata](/current/api/metadata/header/) is defined. No argument is required by default:

```js
nikita
// highlight-next-line
.log.cli()
// No header, no report
.fs.remove({
  target: '/tmp/nikita/a_file_exists'
})
// Header with status as true
.file.touch({
  // highlight-next-line
  $header: 'A file exists, 1st try',
  target: '/tmp/nikita/a_file_exists'
})
// Header with status as false
.file.touch({
  // highlight-next-line
  $header: 'A file exists, 2nd try',
  target: '/tmp/nikita/a_file_exists'
})
```

It outputs like this:

```
localhost   A file exists, 1st try   ✔  192ms
localhost   A file exists, 2nd try   -  65ms
localhost      ♥  
```

An action marked as [disabled](/current/api/metadata/disabled/) or which doesn't pass a [condition](/current/guide/conditions/) is not reported to stdout:

```js
nikita
// highlight-next-line
.log.cli()
// Disabled action
.call({
  // highlight-next-line
  $disabled: true,
  $header: 'I am not printed'
})
// Condition is not passed
.call({
  // highlight-next-line
  $header: 'Me neather',
  $if: false,
})
```

Output to CLI can be customized using [available configuration properties](/current/actions/log/cli/#schema). For example, this configuration changes the spacing between host and header messages:

```js
nikita
.log.cli({
  // highlight-range{1-4}
  pad: {
    host: 20,
    header: 40
  },
})
```

## CSV and Markdown logs

Both `nikita.log.csv` and `nikita.log.md` actions use the `nikita.log.fs` with a custom serializer. Thus, they support all the [configuration properties](/current/actions/log/fs/#schema) of the `nikita.log.fs` action.
