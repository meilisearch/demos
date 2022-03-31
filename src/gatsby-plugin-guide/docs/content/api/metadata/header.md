---
navtitle: header
---

# Metadata "header"

The `header` metadata is mostly used as a reporting mechanism and provides a title to a group of actions. It leverages the parent-child nature of Nikita to provided a notion of a hierarchical header. In terms of semantic, think about Nikita's header like you would do with an HTML header (`H1`, `H2`, `H3`, ...).

* Type: `string`
* Default: `undefined`

## Usage

Its value is a string describing what the action is about.

By default, defining a `header` to your action won't have any consequences. To see it in action, you will need to activate a reporting solution that honors the `header` metadata or create one on your own.

### CLI reporting

The CLI reporting leverages the metadata to print the name of executed action to the user console. The following code:

 ```js
 nikita
 // highlight-next-line
 .log.cli()
 .call({
   // highlight-next-line
   $header: 'My App'
 }, function(){
   this.file.yaml({
     // highlight-next-line
     $header: 'Configuration',
     target: '/tmp/my_app/config.yaml',
     content: { http_port: 8000 }
   })
 })
 ```

Will generate a similar output to the console:

```
localhost   My App : Configuration   ✔  93ms
localhost   My App   ✔  95ms
```

### Markdown reporting

In a similar fashion, the Markdown reporting will print Markdown style header to a file. The following code:

```js
nikita
.log.md({
  basedir: '/tmp/my_app/log'
})
.call({
  $header: 'My App'
}, function(){
  this.file.yaml({
    $header: 'Configuration'
    target: '/tmp/my_app/config.yaml',
    content: { http_port: 8000 }
  })
})
```

Will write a similar output:

```md
# My App

...

## My App : Configuration
```
