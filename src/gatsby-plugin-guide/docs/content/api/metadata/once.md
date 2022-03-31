---
disabled: true
navtitle: once
---

# Metadata "once" (boolean|array|string, optional, false)

The "once" metadata compare multiple actions in a Nikita session and ensure that the same actions are only executed once.

## Usage

If `true`, all the config will be compared, included values defined as function. Here is an example:

```js
require('nikita')
.call({$once: true}, function(){
  console.info('This message will appear only one time')
})
.call({$once: true}, function(){
  console.info('This message will appear only one time')
})
```

If a string or an array of strings, only the listed config will be compared:

```js
require('nikita')
.call({$once: ['key_a', 'key_b'], key_a: 'a', key_b: 'b'}, function(){
  console.info('This action is called')
})
.call({$once: ['key_a', 'key_b'], key_a: 'a', key_b: 'b'}, function(){
  console.info('This action is never called')
})
```
