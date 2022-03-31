---
navtitle: module
related:
- /api/metadata/namespace/
---

# Metadata "module"

The `module` metadata identifies the location of the Node.js module defining the action. In Node.js, a module is a file. When an action is loaded from a module name, it is resolved internally with the `require.main.require` function which applies the Node.js module discovery relative to the main module and the current working directory.

* Type: `string`
* Read-only

The value of the metadata is defined when [registering an action](/current/guide/registry/) and is primarily used internally to indicate the module location in functionality such as [logging and debugging](/current/guide/logging_debugging/).

## Usage

Its value is accessed inside the [action handler](/current/api/handler/).

```js
nikita
.call(({metadata: {module}}) => {
  // Print the value
  console.info(module) // @nikitajs/core/lib/actions/call
})
```

## Debugging

Logs export the `module` name from where the log message was emited. It is used to report context information. For example, the `$log` property returned by an action include the property:

```js
const {$logs} = await nikita
.fs.mkdir({
  target: '/tmp/a_dir'
}, ({tools: {log}}) => {
  log('hello')
})
console.info($logs)
// Print something like:
// {
//   ...
//   message: 'hello',
//   ...
//   module: '@nikitajs/core/lib/actions/fs/mkdir',
//   ...
// }
```

It is possible to call a registered action and switch its `handler` function for debugging purpose or to customize its behavior, for example implementing a quick fix or a feature. Here is an example:

```js
nikita
.fs.mkdir({
  target: '/tmp/a_dir'
}, ({config: {target}, metadata: {module}})){
  console.info(`Action ${module} receives target ${target}`)
}
```
