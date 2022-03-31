---
description: Registration API - register and access actions by names
keywords: registry, API, actions
sort: 3
---

# Action Registration

The registration API allows actions to be registered and accessed by names.

To write an action commonly involves writing a function and schedule it for execution by using the `call` action:

```js
nikita
// Call an action
.call(function(){
  // Handler implementation
  this.service('redis')
  this.file.properties({
    target: '/etc/redis.conf',
    content: { port: 6379 },
    separator: ' '
  })
})
```

This is appropriate for specific usages. However, it is sometimes better to encapsulate the code and make it available to everyone by its name. In such cases, you can register a Nikita action. It can be registered globally to every Nikita instance or locally to a single instance.

## Global registration

When registered globally, the action will be made available to every Nikita instance.

For example, the action above can be registered and accessed by the name `nikita.redis.install`. Additionally, it is isolated in a separate file "./redis/install.js":

```js
// Import the registry module
const registry = require('@nikitajs/core/lib/registry');
// Registering
registry.register(['redis', 'install'], function({config}){
  // Handler implementation
  if(!config.conf_file){
    config.conf_file = '/etc/redis.conf'
  }
  if(!config.properties){
    config.properties = {}
  }
  if(!config.properties.port){
    config.properties.port = 6379
  }
  this.service('redis')
  this.file.properties({
    target: config.conf_file,
    content: config.properties,
    separator: ' '
  })
})
```

Now, anyone can require the above module and call the action:

```js
require('./redis/install');
// Call the globally registered action
nikita.redis.install()
```

## Local registration

When registered locally, the action is only available from one Nikita instance, without modifying the global scope.

For example, the action above which is isolated in the file "./redis/install.js" can be re-written as:

```js
module.exports = function({config}){
  // Handler implementation
  if(!config.conf_file){
    config.conf_file = '/etc/redis.conf'
  }
  if(!config.properties){
    config.properties = {}
  }
  if(!config.properties.port){
    config.properties.port = 6379
  }
  this.service('redis')
  this.file.properties({
    target: config.conf_file,
    content: config.properties,
    separator: ' '
  })
}
```

Now, a new Nikita instance can be created from which a new action will be registered:

```js
nikita
// Registering
.registry.register(['redis', 'install'], './redis/install')
// Call the locally registered action
.redis.install()
```

## API

The following methods are available:

* `nikita.registry.create(options)`   
  Create a new registry.
* `nikita.registry.get(name, options)`   
  Retrieve an action by name.
* `nikita.registry.register(name, handler)`   
  `nikita.registry.register(actions)`   
  Register new actions.
* `nikita.registry.registered(name)`   
  Test if a function is registered or not.
* `nikita.registry.unregister(name)`
  Remove an action from registry.

## Registration examples

It is possible to register one action or multiple actions at once. Also, as illustrated from the above example, the name referencing an action can be composed of one or multiple properties.

With an action path:

```js
nikita
// Register
.registry.register('first_action', 'path/to/action')
// Call
.first_action()
```

With a namespace and an action path:

```js
nikita
// Register
.registry.register(['second', 'action'], 'path/to/action')
// Call
.second.action()
```

With an action object:

```js
nikita
// Register
.registry.register('third_action', {
  handler: ({config}) => {
    // Handler implementation
    console.info(config)
  }
})
// Call
.third_action(config)
```

With a namespace and an action object:

```js
nikita
// Register
.registry.register(['fourth', 'action'], {
  handler: ({config}) => {
    // Handler implementation
    console.info(config)
  }
})
// Call
.fourth.action(config)
```

Multiple actions:

```js
nikita
// Register
.registry.register({
  'fifth_action': 'path/to/action'
  'sixth': {
    '': 'path/to/sixth',
    'action': : 'path/to/sixth/action'
  }
})
// Call
.fifth_action()
// Call
.sixth()
// Call
.sixth.action()
```
