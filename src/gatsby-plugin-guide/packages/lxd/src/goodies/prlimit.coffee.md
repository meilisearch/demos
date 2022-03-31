
# `nikita.lxc.goodies.prlimit`

Print the process limit associated with a running container.

Note, the command must be executed on the host container of the machine. When
using a remote LXD server or cluster, you must know on which node the machine is running
and run the action in this node.

## Output

* `error` (object)
  The error object, if any.
* `output.stdout` (string)
  The standard output from the `prlimit` command.
* `output.limits` (array)
  The limit object parsed from `stdout`; each element of the array contains the
  keys `resource`, `description`, `soft`, `hard` and `units`.

## Example

```js
const {stdout, limits} = await nikita.lxc.goodies.prlimit({
  container: "my_container"
})
console.info( `${stdout} ${JSON.decode(limits)}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
        required: ['container']

## Handler

    handler = ({config}) ->
      try
        {stdout} = await @execute
          command: """
          command -p prlimit || exit 3
          sudo prlimit -p $(lxc info #{config.container} | awk '$1==\"Pid:\"{print $2}')
          """
        limits = for line, i in utils.string.lines stdout
          continue if i is 0
          [resource, description, soft, hard, units] = line.split /\s+/
          resource: resource
          description: description
          soft: soft
          hard: hard
          units: units
        stdout: stdout, limits: limits
      catch err
        err = errors.NIKITA_LXC_PRLIMIT_MISSING() if err.exit_code is 3
        throw err

## Errors

    errors =
    NIKITA_LXC_PRLIMIT_MISSING: ->
      utils.error 'NIKITA_LXC_PRLIMIT_MISSING', [
        'this action requires prlimit installed on the host'
      ]

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
        shy: true

## Dependencies

    utils = require '../utils'
