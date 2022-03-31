---
sort: 7
---

# Control Flow

Nikita runs every action sequentially. This behavior ensures there are no conflicts between two commands executed simultaneously. Moreover, this sequential nature is aligned with SSH which executes one command at a time over a given connection.

## Sequential execution

Since an action may contain child actions, the way Nikita runs is similar to how you might want to traverse a file system. For every action scheduled, Nikita will run its children recursively before passing to the next scheduled action. 

Let's imaging we want to install 2 packages `my_pkg_1` and `my_pkg_2` before modifying a configuration file:

```js
nikita
.call(function() {
  this.service('my_pkg_1')
  this.service('my_pkg_2')
})
.file.yaml({
  target: '/etc/my_pkg/config.yaml',
  content: { my_property: 'my value' }
})
```

The actions will be executed in this sequence:

* (1) `call`
  * (2) `service` for `my_pkg_1`
  * (3) `service` for `my_pkg_2`
* (4) `file.yaml`

This tree-like traversal is leverage by the [`header` metadata](/current/api/metadata/header/) and the `log.cli` action to display a report to the terminal.

```js
nikita
.log.cli({pad: {header: 20}})
.call({
  // highlight-next-line
  $header: 'Packages'
}, function() {
  this.service({
    // highlight-next-line
    $header: 'My PKG 1'
  }, 'my_pkg_1')
  this.service({
    // highlight-next-line
    $header: 'My PKG 2'
  }, 'my_pkg_2')
})
.file.yaml({
  // highlight-next-line
  $header: 'Config',
  target: '/etc/my_pkg/config.yaml',
  content: { my_property: 'my value' }
})
```

Will output like this:

```
localhost   Packages : My PKG 1  ✔  1ms
localhost   Packages : My PKG 2  ✔  1ms
localhost   Packages             ✔  3ms
localhost   Config               ✔  10ms
```

> Note, to make this example working, you have to change package names to real packages supported by your OS.

## Interrupting the execution

The native Nikita scheduler interrupts the global Nikita session in case of failure of any action. This behavior prevents error propagation to the next actions. In the following example, the second action will not be executed because the first one throws an exception:

```js
nikita
// Throws an exception
.call(() => {
  throw Error('Oh my God!')
})
// Is not executed
.call(() => {
  console.info('I am not executed.')
})
```

However, the session can be preserved by catching the exception thrown by action [Promise](https://nodejs.dev/learn/understanding-javascript-promises). The example below uses the `try...catch` statement to handle the exception:

```js
nikita
.call(async function() {
  // highlight-range{1-8}
  try {
    // Throws an exception
    await this.call(() => {
      throw Error('Oh my God!')
    })
  } catch(err) {
    console.info(err.message)
  }
  // Is executed
  this.call(() => {
    console.info('I am executed the error is catched.')
  })
})
```

## Condition and status

The execution flow can be controlled by mixing [conditions](/current/guide/conditions/) and [output](/current/api/output/) such as [`status`](/current/api/output/status/) and [`error`](/current/guide/error/) returned with Promise.

> Note, Nikita's actions always return [Javascript Promise](https://nodejs.dev/learn/understanding-javascript-promises). To access the action output, you have to call an asynchronous function and "await" for the result of Promise.

The example below demonstrates the combination of the `status` output variable and the [`if` condition](/current/guide/conditions/). The second action is executed if the status is `true`:

```js
nikita
.call(async function() {
  // Get status of the 1st action
  // highlight-next-line
  const {$status} = await this.execute({
    command: 'echo catchme | grep catchme' // Returns status true
  })
  // Run the 2nd action if status is true
  this.call({
    // highlight-next-line
    $if: status
  }, function(){
    console.info('The condition passed, because the status is true')
  })
})
```

In the following example, the second action is executed if the first one is failed. To prevent throwing an exception the [relax behavior](/current/api/metadata/relax/) is enabled:

```js
nikita
.call(async function() {
  // Get error of the 1st action
  // highlight-next-line
  const {error} = await this.execute({
    $relax: true,  // Don't throw an error if occured
    command: 'echo missyou | grep catchme' // fails
  })
  // Run the 2nd action if error
  this.call({
    // highlight-next-line
    $if: error
  }, function(){
    console.info('The condition passed because an error occured')
  })
})
```
