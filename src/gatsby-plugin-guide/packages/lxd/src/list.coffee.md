
# `nikita.lxc.list`

List the instances managed by LXD.

## Example

```js
const { list } = await nikita.lxc.list({
  filter: "containers",
});
console.info(`LXD containers: ${list}`);
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'filter':
            type: 'string'
            enum: ['containers', 'virtual-machines', 'instances']
            default: 'instances'
            description: """
            Display only one type of instances.
            """

## Handler

    handler = ({config}) ->
      {data} = await @lxc.query
        $shy: false
        path: "/1.0/#{config.filter}"
      list: (i.split('/').pop() for i in data)

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true
