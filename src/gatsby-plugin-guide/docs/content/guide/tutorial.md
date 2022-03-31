---
description: Instructions on how to get up and running
sort: 1
---

# Tutorial

This tutorial covers the basics to get started and to use Nikita. It is organized in 4 sections:

- [What is Nikita?](#what-is-nikita)
- [Installation instructions](#installation-instructions)
- [Core concepts](#core-concepts)
- [Real-life example](#real-life-example)

Feel free to skip the second section if you are familiar with Node.js and its ecosystem.

For detailed information, navigate the documentation or submit an issue if you don't find the answers to your questions. Also, if you are looking for examples, the source code is well documented and its test coverage quite complete. We highly encourage you to navigate the tests. Tests are self-contained and very easy to understand. They also provide you the guaranty of reading a working code.

## What is Nikita?

Nikita is a toolkit to automate the execution of deployment workflows. Use one of the [many available actions](/current/actions/) or create your own functions to build simple to complex deployment pipelines and infrastructures. Actions are transparently executed locally or remotely over SSH from any host.

### Technologies

Nikita is written in JavaScript and executed with Node.js. It is available on [NPM](https://www.npmjs.com/package/nikita).

### Use cases

It serves multiple purposes. For example, it can be used in a website with a Node.js backend, where you want to execute actions (writing files, copy, move, executing custom scripts...) or you can use it to automate and orchestrate components' deployments (installations, functional tests, lifecycle management...).

Take a view at [Ryba](https://github.com/ryba-io/ryba) which contains playbooks to set up and manage Big Data systems.

### Supported platforms

Nikita targets Unix-like systems including Linux and macOS. Windows is not supported as a targeting node where actions are executed. It is however known to work as a Nikita host. This means you can run Nikita from a Windows host and target Linux nodes over SSH.

Throughout this tutorial, it is assumed you work on Linux or macOS. To be able to run the same code examples without modifications on Windows, you can install a Linux virtual machine or use Docker.

At the end of the tutorial, you will learn how to use Nikita over SSH. This way, your Windows host is used to create your workflow and you can target a remote host like a server, a virtual machine, or a container.

### What is inside Nikita?

Nikita comes with a set of default functions. It is bundled with many handy functions covering a large range of usages:

- write files
- execute shell commands
- package-management
- run docker containers

You are encouraged to extend Nikita with your own [actions](/current/api/). In its simplest form, writing an action is just about writing a plain vanilla JavaScript function.

## Installation instructions

### Dependencies

To run your code, you must have Node.js and NPM (or YARN) installed. The procedure depends on your operating system. There are multiple alternatives to install Node.js:

- [Download](https://nodejs.org/en/download/)   
  The [official download page](https://nodejs.org/en/download/) provides you with the choices of downloading an installer, the binary files, and the source code.
- [Package manager](https://nodejs.org/en/download/package-manager/)   
  The [package manager](https://nodejs.org/en/download/package-manager/) is probably the fastest and easiest way to get Node.js installed and ready while being upgraded in the future. The choice of package managers will depend on your system.
- Node.js version manager
  [NVM](https://github.com/creationix/nvm) and [N](https://github.com/tj/n) will manage multiple versions of Node.js in parallel. For advanced users, this is the recommended procedure. We personally use [N](https://github.com/tj/n).

Once installed, you should have the `node` and `npm` commands available from your terminal.

### Initialization

A Nikita project is commonly a Node.js package. Everything is a file and it doesn't require you to rely on any external software such as a database. For this reason, it naturally integrates with [version control systems (VCS)](https://en.wikipedia.org/wiki/Version_control) to track development iterations. Several tools are available such as [Git](https://git-scm.com/) and [Mercurial](https://www.mercurial-scm.org/). In this tutorial, we will be using [Git](https://git-scm.com/) and publish the source code to the [node-nikita-tutorial repository on GitHub](https://github.com/adaltas/node-nikita-tutorial).

We start by initializing a new Git project:

```bash
# Create a new folder
mkdir tutorial
cd tutorial
# Initialize the git repository
git init
# Change the URL with your remote repository URL
git remote add origin https://github.com/adaltas/node-nikita-tutorial.git
# Ignore files
cat > .gitignore <<MD
.*
/node_modules
!.gitignore
MD
# Generate the readme file
cat > README.md <<MD
# Nikita tutorial

You will learn how to create a new project as well as the fundamentals of using
Nikita to automate the deployment of systems.

Please refer to the [official project documentation](http://nikita.adaltas.com/current/guide/tutorial/)
for additional information.
MD
# Commit to git the project description
git add .gitignore README.md
git commit -m "Project description"
```

A Nikita project is a Node.js project. Thus, we will use the `npm init` command to create a new project. This is a common way to bootstrap a project with a default package definition file. The project's unique required dependency is `nikita`. There is no other external dependency to declare unless you need to.

```bash
# Initialize a new project
npm init
# Declare the Nikita dependency
npm add nikita
curl https://raw.githubusercontent.com/adaltas/node-nikita/master/LICENSE -o LICENSE
# Commit to git the Node.js package declaration file
git add package.json package-lock.json LICENSE
git commit -a -m "Package declaration file"
```

The `npm init` command will ask you a few questions such as the project name and its version. You may run with default answers using the `-y` option or get inspiration from this output:

```
package name: (tutorial) nikita-tutorial
version: (1.0.0) 0.0.0
description: Learn how to use Nikita
entry point: (index.js) app.js
test command: mocha test/*.js
git repository: https://github.com/adaltas/node-nikita-tutorial.git
keywords: nikita tutorial
author: David Worms
license: (ISC) BSD-3-Clause
```

A [list of possible licenses](https://gist.github.com/robertkowalski/7620849) is available on Github.

## Core concepts

Before installing something useful, let's learn a few basics. Nikita is executed by the Node.js engine. It implies some experience in JavaScript. You don't need to be a JS Ninja but some basic knowledge is required.

### About CoffeeScript

This tutorial is written in JavaScript to get you started quickly. If you navigate the Nikita source code, you'll see it is written in CoffeeScript, a language that transpiles into JavaScript before being executed by the Node.js engine. Run `npm install -g coffeescript` to install CoffeeScript globally. Unless you used a Node.js version manager, you will probably encounter a permission error. Read the NPM chapter about [permissions](https://docs.npmjs.com/getting-started/fixing-npm-permissions) to select a solution or install it locally without the `-g` option and use the command `npx coffee` instead of `coffee`. The `npx` command is available within all Node.js installation.

CoffeeScript has a very clean syntax and is perfectly suited to the declarative aspect of the Nikita API. In the end, the source code looks like one written in YAML while preserving the advantages of a procedural language like JavaScript. A second advantage we found with CoffeeScript is its [literate functionality](http://coffeescript.org/#literate) which lets you write Markdown files with CoffeeScript code inside. Your source code looks a bit like a Notebook, it is a markdown document with documentation and code organized in blocks.

### Action

An action is the basic building block in Nikita. It is basically a function, called a handler, with some associated configuration, called `config`. It is materialized as a JavaScript object, for example:

```js
{
  who: 'leon',
  $handler: function({config}) {
    console.info(config.who)
  }
}
```

As you can see, `config` is made available as a destructure property of the first argument that the handler receives.

### Calling actions

To execute an action, you must create a Nikita session and execute the `call` function:

```js
// New Nikita session
nikita
// Call an action
.call({
  who: 'leon',
  $handler: function({config}) {
    console.info(config.who)
  }
})
```

The function `nikita.call` is very flexible in how arguments are passed. It receives zero to multiple objects which will be merged together. Also, a function is interpreted as the action handler, being converted to an object with the `handler` property. It means the previous example could be rewritten as:

```js
// New Nikita session
nikita
// Call an action
.call({
  who: 'leon'
}, function({config}) {
  console.info(config.who)
})
```

### Parent action and children

The Nikita session is organized as a hierarchical tree of actions. The parent is an action of the higher level in the session tree. All Nikita's actions have a parent action except the root Nikita action instantiating a Nikita session. The children are the actions executed in the handler of a parent action using the [`this` keyword](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this):

```js
// Root action
nikita(function() {
  console.info('I am root')
})
// Parent action
.call(function() {
  console.info('I am parent')
  // Child action
  this.call(function() {
    console.info('I am child')
  })
})
```

Alternatively, you can use [JavaScript arrow function expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions) to reduce the syntax. In such a case, to call a child action you must use the [`context` property](/current/api/context/), because arrow functions don't accept a custom `this` binding. `context` is available inside the handler as a property of the first argument:

```js
// Root action
nikita(() => {
  console.info('I am root')
})
// Parent action
.call(({context}) => {
  console.info('I am parent')
  // Child action
  context.call(() => {
    console.info('I am child')
  })
})
```

### Action promise

Nikita's actions always resolve [Javascript Promises](https://nodejs.dev/learn/understanding-javascript-promises), they either fulfill with an action output or reject an error. To access the [action output](/current/api/output/), you have to use the Promise API or simply use the [`async/await` construction](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await) to get the returned value.

```js
// Call asynchronous function
(async () => {
  // Define empty array
  history = []
  // Access the action output
  const result = await nikita.call(() => 'first')
  // Run next synchronous function
  history.push(result)
  // Print array
  console.info(history) // [ 'first' ]
})()
```

Nikita also provides you the guarantee that your actions are executed sequentially. The following example is calling 3 asynchronous actions of various duration. The `history` array records their order of execution:

```js
const assert = require('assert');
(async () => {
  // Define empty array
  var history = []
  // Await result from Promise
  var result = await nikita(async function() {
    // Call 1st action
    this.call(() => {
      // Fulfilled in 200ms
      return new Promise((resolve) => {
        setTimeout(() => {
          history.push('first')
          resolve()
        }, 200)
      })
    })
    // Call 2nd action
    this.call(() => {
      // Fulfilled in 100ms
      return new Promise((resolve) => {
        setTimeout(() => {
          history.push('second')
          resolve()
        }, 100)
      })
    })
    // Return 3rd action
    return this.call(() => {
      return 'done'
    })
  })
  // Assert sequential execution
  assert.equal(result, 'done')
  assert.deepEqual(history, ['first','second'])
})()

```

### Error handling

However, since actions returned promises, they cannot throw errors and stop the execution flow. To ensure errors are properly handled, it is your responsibility to raise them.

The above example must be rewritten to raise errors. For example, using the `await` keyword, a simpler code looks like:

```js
const assert = require('assert');
(async () => {
  try {
    await nikita(async function() {
      await this.call(function() {
        console.info('called')
      })
      await this.call(function() {
        throw new Error('catch me')
      })
      await this.call(function() {
        console.error('never called')
      })
    })
  } catch(err) {
    assert.equal(err.message, 'catch me')
  }
})()
```

### Cascading outputs and errors

Instead of throw an error, it is also possible to return the promise of a child action. This way, both resolved output and errors are cascaded up to the parent actions:

```js
(async () => {
  try {
    const {date} = await nikita(function() {
      return this.call(function() {
        return this.call(function() {
          const today = new Date()
          if((today).getDate() === 1) {
            return {date: today}
          } else {
            throw Error("Today is not the first day of the month")
          }
        })
      })
    })
    console.info(date)
  } catch(err) {
    console.error(err.message)
  }
})()
``` 

### Passing `metadata`

Several properties are generic and globally available for every action. Examples include the `header`, `retry` and `relax` properties. Those are called [metadata properties](/current/api/metadata/).

They are not to be confused with [configuration properties](/current/api/config/). A configuration property is declared and used by a single action. A metadata property applies to multiple if not all actions and are usually declared inside a plugin.

To avoid naming collisions with configuration properties, metadata properties are prefixed with a dollar sign (`$`) and are available inside the action under the `metadata` property:

```js
nikita({
  $retry: 3
}, async function({metadata: {attempt, retry}}) {
  if(attempt < retry) {
    console.info(`Attempt ${attempt} out of ${retry}`)
    throw new Error('Please retry')
  } else {
    return true
  }
})
// Prints:
// Attempt 0 out of 3
// Attempt 1 out of 3
// Attempt 2 out of 3
```

Note, the majority of properties prefixed with `$` are metadata properties. There are however a few exceptions including `$handler`, `$plugins`, `$ssh` as well as all [condition](/current/guide/conditions/) and [assertion](/current/guide/assertions/) properties.

### Idempotence and status

In the context of software deployment, idempotence means that an action with the same parameters can be executed multiple times without changing the final state of the system. It is a fundamental concept and every action in Nikita follows this principle.

The status is used and interpreted with different meanings but in most cases, it indicates that a change occurred. Read each action documentation in case of any doubt. For example, an action similar to the POSIX `touch` command could be designed to return `true` on its first run and `false` later on because the file already exists:

> Important: you will encounter an error the second time you execute this code because the target file will be present and status will be set to `true` instead of `false`. Simply remove the file with `rm /tmp/a_file` between each run to overcome this issue.

```js
// Dependencies
const assert = require('assert');
const fs = require('fs').promises;
// Touch implementation
const touch = async ({config}) => {
  try { 
    await fs.stat('/tmp/a_file')
    return false
  } catch (err) {
    if (err.code !== 'ENOENT') throw err
    await fs.writeFile('/tmp/a_file', '')
    return true
  } 
}
// Calling actions
(async () => {
  // First time calling touch
  var {$status} = await nikita.call(touch)
  assert.equal($status, true)
  // Second time calling touch
  var {$status} = await nikita.call(touch)
  assert.equal($status, false)
})()
```

Note, there is an existing `nikita.file.touch` action which does just that with additional functionalities such as detecting and applying changes of ownerships and permissions.

### External actions

In order to reuse our new `touch` action, we could isolate it into a separate file. The new file is called a module in Node.js terminology. Nikita `call` will accept the exported object or function. Let's create two files "./lib/touch.js" and "app.js":

File "./lib/touch.js":

```js
// Dependencies
const fs = require('fs').promises;
// Touch implementation
module.exports = async ({config}) => {
  try { 
    await fs.stat('/tmp/a_file')
    return false
  } catch (err) {
    if (err.code !== 'ENOENT') throw err
    await fs.writeFile('/tmp/a_file', '')
    return true
  } 
}
```

File "./app.js":

```js
// Dependencies
const assert = require('assert');
(async () => {
  // New Nikita session
  var {$status} = await nikita.call('./lib/touch')
  assert.equal($status, true)
})()
```

### Passing `config`

The `touch` action is now a separate Node.js module. It is a vanilla JavaScript function. You can create your own `config` to control the behavior of your actions. In our example, we created the `target` configuration property to know which file to touch:

File "./lib/touch.js":

```js
// Dependencies
const fs = require('fs').promises;
// Touch implementation
module.exports = async ({config}) => {
  try { 
    await fs.stat(config.target)
    return false
  } catch (err) {
    if (err.code !== 'ENOENT') throw err
    await fs.writeFile(config.target, '')
    return true
  } 
}
```

File "./app.js": 

```js
// Dependencies
const assert = require('assert');
(async () => {
  // New Nikita session
  var {$status} = await nikita.call({
    target: '/tmp/a_file'
  }, './lib/touch')
  assert.equal($status, true)
})()
```

### Registering actions

Instead of using the `call` action, it might be more comfortable to call our `touch` action by its name. To do so, we will register it. Actions can be registered in the current Nikita session or globally. In the example below, we will register it in the session:

```js
// Dependencies
const assert = require('assert');
(async () => {
  // New Nikita session
  var {$status} = await nikita
  // Register the touch action
  .registry.register({touch: './lib/touch'})
  // Calling the registered action
  .touch({target: '/tmp/a_file'})
  // Validation
  assert.equal($status, true)
})()
```

## Real-life example

For the sake of this tutorial, we will create a basic Redis installation. The installation steps are:

1. Source compilation   
  *Learn how to execute shell commands and use conditions.*
2. Redis configuration file   
  *Learn how to merge or overwrite a configuration by serializing a JavaScript vanilla object.*
3. CLI reporting and logs   
  *Learn how to activate pretty reporting and detailed logs written in Markdown.*
4. Get the server up and running   
  *Learn how to leverage exit code to alter the action status.*
5. Checking the service health   
  *Learn how to use the `relax` and `shy` metadata.*
6. SSH activation   
  *Learn how easy and transparent it is to activate SSH.*
7. Composition   
  *Learn how to chain multiple actions sequentially and compose them as children of other actions.*

### 1. Source compilation

*Learn how to execute shell commands and use conditions.*

Following the [Redis quickstart guide](https://redis.io/topics/quickstart), getting Redis up and ready is about downloading the package and executing the `redis-server` command. We will do this with idempotence in mind.

The existing `nikita.file.download` action is used to dowload Redis:

```js
(async () => {
  var {$status} = await nikita.file.download({
    source: 'http://download.redis.io/redis-stable.tar.gz',
    target: '/tmp/nikita-tutorial/cache/redis-stable.tar.gz'
  })
  console.info('Redis downloaded:', $status ? '✔' : '-')
})()
```

The second time `nikita.file.download` is called, it checks if the target exists and bypasses the download in such case, thus speeding up the execution. You could also adjust this behavior based on the file signature by using one of the "md5", "sha1" and "sha256" configuration properties.

To extract and compile Redis, a custom shell script is only be executed if a specific generated file does not already exist. Nikita comes with a few native conditions prefixed with "$if_" and their associated negation prefixed with "$unless_". The `nikita.execute` action to execute shell scripts:

```js
(async () => {
  var {$status} = await nikita.execute({
    $unless_exists: '/tmp/nikita-tutorial/redis-stable/src/redis-server',
    command: `
    tar xzf /tmp/nikita-tutorial/cache/redis-stable.tar.gz -C /tmp/nikita-tutorial
    cd /tmp/nikita-tutorial/redis-stable
    make
    `
  })
  console.info('Redis compiled:', $status ? '✔' : '-')
})()
```

It is annoying and not flexible to always provide the same an absolute base directory like "/tmp/nikita-tutorial" each time. Among many others, the `nikita.execute` action comes with the `cwd` configuration property. The acronym stands for "current working directory". The command is rewritten as:

```js
(async () => {
  var {$status} = await nikita.execute({
    $unless_exists: '/tmp/nikita-tutorial/redis-stable/src/redis-server',
    command: `
    tar xzf cache/redis-stable.tar.gz
    cd redis-stable
    make
    `,
    cwd: '/tmp/nikita-tutorial',  // Define current working directory
  })
  console.info('Redis compiled:', $status ? '✔' : '-')
})()
```

### 2. Redis configuration file

*Learn how to merge or overwrite a configuration by serializing a JavaScript vanilla object.*

Before starting the server, we create a configuration file. The Redis format is made of key-value pairs separated by spaces. This type of format can be handled with the `nikita.file.properties` action with a custom `separator` configuration set to one space. The action also comes with some handy config like `comment` to preserve comments and `merge` to preserve the properties already present in the file. 

```js
(async () => {
  var {$status} = await nikita.file.properties({
    content: {
      'bind': '127.0.0.1',
      'daemonize': 'yes',
      'protected-mode': 'yes',
      'port': 6379
    },
    separator: ' ',
    target: '/tmp/nikita-tutorial/conf/redis.conf',
  })
  console.info('Redis configuration set:', $status ? '✔' : '-')
})()
```

### 3. CLI reporting and logs

*Learn how to activate pretty reporting and detailed logs written in Markdown.*

So far, we retrieved the action output to manually print a message for the user with the `console.info` function completed by character depending the the execution status. This process is automatically managed by the `nikita.log.cli` action. A message is printed to the user terminal whenever the `header` metadata property is present:

```js
nikita(async function() {
  // Activate CLI reporting
  await this.log.cli()
  // Call any action
  await this.file.properties({
    $header: 'Redis configuration', // CLI messages
    content: {
      'bind': '127.0.0.1',
      'daemonize': 'yes',
      'protected-mode': 'yes',
      'port': 6379,
    },
    separator: ' ',
    target: '/tmp/nikita-tutorial/redis-stable/redis.conf',
  })
})
```

The message contains information such as the hostname or the IP address where the action is executed, the custom header, the status symbol, and the time of execution. It ends with `♥` to indicate the termination of the Nikita session:

```bash
localhost   Redis configuration   ✔  109ms
localhost      ♥  
```

What if an action failed and the error message is not explicit enough? What if a system command failed and we need to dig and get detailed information? Nikita doesn't have to run as a black box. Multiple error reporting actions are made available such as the `nikita.log.md` which writes logs in the Markdown format:

```js
nikita(async function() {
  // Activate Markdown reporting
  await this.log.md({
    basedir: '/tmp/nikita-tutorial/log'
  })
  // Call any action
  await this.file.properties({
    // The Markdown header
    $header: 'Redis configuration',
    content: {
      'bind': '127.0.0.1',
      'daemonize': 'yes',
      'protected-mode': 'yes',
      'port': 6379
    },
    separator: ' ',
    target: '/tmp/nikita-tutorial/conf/redis.conf',
  })
})
```

Under the hood, both the `nikita.log.cli` and the `nikita.log.md` actions leverage the native Node.js [event API](https://nodejs.org/api/events.html). You can get more detailed information by visiting the [Logging and Debugging](/current/guide/logging_debugging/) documentation.

Finally, if you need to quickly access verbose debugging information, use the `debug` metadata property:

```js
nikita({
  $debug: true
}, async function() {
  await this.file.properties({
    // The Markdown header
    $header: 'Redis configuration',
    content: {
      'bind': '127.0.0.1',
      'daemonize': 'yes',
      'protected-mode': 'yes',
      'port': 6379
    },
    separator: ' ',
    target: '/tmp/nikita-tutorial/conf/redis.conf',
  })
})
```

### 4. Get the server up and running

*Learn how to leverage exit code to alter the action status.*

The Redis server is now configured and ready to be started. The status reflects whether the server was already started or not based on the [shell exit code](https://tldp.org/LDP/abs/html/exitcodes.html). The value `0` will indicate that the server was started, the value `42` will indicate that it was already running and any other exit code will be treated as an error.

```js
nikita(async function() {
  await this.log.cli()
  await this.execute({
    $header: 'Startup',
    code_skipped: 42,
    command: `
    # Exit code 3 if ping is successful
    redis-stable/src/redis-cli ping && exit 3
    # Otherwise start the server
    nohup redis-stable/src/redis-server conf/redis.conf &
    `,
    cwd: '/tmp/nikita-tutorial',
  })
})
```

### 5. Checking the service health

*Learn how to use the `relax` and `shy` metadata.*

The Redis `PING` command is expected to return `PONG` if the server is healthy. Let's take this use case to illustrate the usage of the `relax` and `shy` metadata properties.

The `relax` metadata resolves the action successfully with the error placed inside the resulting output instead of rejecting the exception, thus allowing the Nikita session to exit gracefully while printing `✘` in case of any error. 

Similarly, the `shy` metadata will allow us to set the status to `true`, but print `-` on success without modifying the status of the parent `nikita.call` action, because it is not considered as a change of state.

```js
nikita(async function() {
  await this.log.cli()
  await this.call({
    $header: 'Redis Check',
  }, function() {
    this.execute({
      $header: "Check",
      $relax: true,
      $shy: true,
      cwd: '/tmp/nikita-tutorial',
      command: 'redis-stable/src/redis-cli -h 127.0.0.1 -p 6379 ping | grep PONG'
    })
  })
})
```

When the Redis server is started, it prints:

```
localhost   Redis Check : Check   -  12ms
localhost   Redis Check   -  18ms
localhost      ♥  
```

Running the same code without `shy: true` would print:

```
localhost   Redis Check : Check   ✔  13ms
localhost   Redis Check   ✔  18ms
localhost      ♥  
```

When the Redis server is not started, it prints: 

```
localhost   Redis Check : Check   ✘  12ms
localhost   Redis Check   -  17ms
localhost      ♥  
```

### 6. SSH activation

*Learn how easy and transparent it is to activate SSH.*

Nikita is written from the ground up to be transparent whether it is executed locally or over SSH. In fact, [the majority of the tests](/project/developers/#tests-execution) are contextualized with an ssh argument and are executed twice. The first time locally when the connection is set to null and the second time remotely with an SSH configuration object.

Calling `nikita.ssh.open` and `nikita.ssh.close` will associate Nikita's current session with and without an SSH connection. The `nikita.ssh.open` action must be registered before scheduling any other actions and, inversely, the `nikita.ssh.close` action must be registered last. 

> Note: both the `nikita.log.cli` and `nikital.log.md` actions are always executed locally. When SSH is setup, passing the `$ssh` property to actions may activate and deactivate the SSH connection.

```js
nikita(async function() {
  await this.log.cli()
  // Open the SSH Connection
  await this.ssh.open({
    $header: 'SSH open',
    host: '127.0.0.1',
    port: 22,
    private_key_path: '~/.ssh/id_rsa',
    username: process.env.USER
  })
  // Call one or multiple actions
  await this.call(() => {
    console.info('Business as usual')
  })
  // Close the SSH Connection
  await this.ssh.close({
    $header: 'SSH close',
  })
})
```

The above example assumes that you can self connect with SSH locally. If this is not the case, SSH must be installed and listening on port 22 and you must follow the instructions targeting your operating system to get it up and running. A pair of SSH private and public keys, respectively installed in the files "~/.ssh/id_rsa" and "~/.ssh/id_rsa.pub", must be present and your public key must be registered inside "~/.ssh/authorized_keys". If this isn't already the case, you can run the following commands:

```bash
# Detect if private key is already present
if [ ! -f ~/.ssh/id_rsa ]; then
  # Generate private and public keys
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
fi
# Allow self access
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# Ensure permissions are valid
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys
# Test access
ssh `whoami`@127.0.0.1 "echo 'I am inside'; exit"
```

### 7. Composition

*Learn how to chain multiple actions sequentially and compose them as children of other actions.*

It is time to finalize our script and run all these actions sequentially. Every time an action is called, it is scheduled inside the internal Nikita session for later execution.

It is also possible to group multiple actions into one action, creating a hierarchical representation and enabling composition. In our example, we will regroup all Redis actions related to the Redis installation into a single action.

```js
const nikita = require('nikita');
const cwd = '/tmp/nikita-tutorial';
nikita(async function() {
  await this.log.cli()
  await this.log.md({
    basedir: `${cwd}/log`
  })
  await this.ssh.open({
    $header: 'SSH Open',
    host: '127.0.0.1',
    port: 22,
    username: process.env.USER,
    private_key_path: '~/.ssh/id_rsa'
  })
  await this.call({
    $header: 'Redis installation',
  }, async function() {
    await this.file.download({
      $header: 'Downloading',
      source: 'http://download.redis.io/redis-stable.tar.gz',
      target: `${cwd}/cache/redis-stable.tar.gz`
    })
    await this.execute({
      $header: 'Compilation',
      $unless_exists: `${cwd}/redis-stable/src/redis-server`,
      cwd: cwd,
      command: `
      tar xzf cache/redis-stable.tar.gz
      cd redis-stable
      make
      `
    })
    await this.file.properties({
      $header: 'Configuration',
      target: `${cwd}/conf/redis.conf`,
      separator: ' ',
      content: {
        'bind': '127.0.0.1',
        'daemonize': 'yes',
        'protected-mode': 'yes',
        'port': 6379
      }
    })
    await this.execute({
      $header: 'Startup',
      cwd: cwd,
      code_skipped: 3,
      command: `
      redis-stable/src/redis-cli ping && exit 3
      nohup redis-stable/src/redis-server conf/redis.conf &
      `
    })
  })
  await this.execute({
    $header: 'Redis Check',
    $relax: true,
    $shy: true,
    cwd: cwd,
    command: 'redis-stable/src/redis-cli -h 127.0.0.1 -p 6379 ping | grep PONG'
  })
  await this.ssh.close({
    $header: 'SSH Close'
  })
})
```

Finally, we will split this code into one file to pilot our application and two files to encapsulate our install and check actions. We will also enhance our actions with a more flexible configuration:

File "app.js":

```js
// Dependencies
const nikita = require('nikita');
const install = require('./lib/install');
const check = require('./lib/check');
// Configuration
const config = {
  ssh: {
    host: '127.0.0.1',
    port: 22,
    private_key_path: '~/.ssh/id_rsa',
    username: process.env.USER
  },
  redis: {
    cwd: '/tmp/nikita-tutorial',
    config: {}
  }
};
// Run the application
(async () => {
  await nikita(async function() {
    await this.log.cli()
    await this.log.md({basedir: '/tmp/nikita-tutorial/log'})
    await this.ssh.open({$header: 'SSH Open'}, config.ssh)
    await this.call({$header: 'Redis Install'}, config.redis, install)
    await this.call({$header: 'Redis Check'}, config.redis, check)
    await this.ssh.close({$header: 'SSH Close'})
  })
})();
```

File "./lib/install.js":

```js
module.exports = async function({config}) {
  // Default configs
  if(!config.url){ config.url = 'http://download.redis.io/redis-stable.tar.gz' }
  if(!config.config){ config.config = {} }
  if(!config.config['bind']){ config.config['bind'] = '127.0.0.1' }
  if(!config.config['daemonize']){ config.config['daemonize'] = 'yes' }
  if(!config.config['protected-mode']){ config.config['protected-mode'] = 'yes' }
  if(!config.config['port']){ config.config['port'] = 6379 }
  // Do the job
  await this.file.download({
    $header: 'Download',
    source: config.url,
    target: `${config.cwd}/cache/redis-stable.tar.gz`
  })
  await this.execute({
    $header: 'Compilation',
    $unless_exists: `${config.cwd}/redis-stable/src/redis-server`,
    cwd: config.cwd,
    command: `
    tar xzf cache/redis-stable.tar.gz
    cd redis-stable
    make
    `
  })
  await this.file.properties({
    $header: 'Configuration',
    target: `${config.cwd}/conf/redis.conf`,
    separator: ' ',
    content: config.config
  })
  await this.execute({
    $header: 'Startup',
    cwd: config.cwd,
    code_skipped: 3,
    command: `
    redis-stable/src/redis-cli ping && exit 3
    nohup redis-stable/src/redis-server conf/redis.conf &
    `
  })
}
```

File "./lib/check.js":

```js
module.exports = async function({config}) {
  // Get option from config if present
  if(config.config){
    if(config.config.host){ config.host = config.config.host }
    if(config.config.port){ config.port = config.config.port }
  }
  // Default configs
  if(!config.host){ config.host = '127.0.0.1' }
  if(!config.port){ config.port = 6379 }
  // Do the job
  return this.execute({
    $header: 'Check',
    $relax: true,
    $shy: true,
    cwd: config.cwd,
    command: `redis-stable/src/redis-cli -h ${config.host} -p ${config.port} ping`
  })
}
```
