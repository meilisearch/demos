
# `nikita.system.mod`

Load a kernel module. By default, unless the `persist` config is "false",
module are loaded on reboot by writing the file "/etc/modules-load.d/{name}.conf".

## Examples

Activate the module "vboxpci" in the file "/etc/modules-load.d/vboxpci.conf":

```
nikita.system.mod({
  modules: 'vboxpci'
})
```

Activate the module "vboxpci" in the file "/etc/modules-load.d/my_modules.conf":

```
nikita.system.mod({
  target: 'my_modules.conf',
  modules: 'vboxpci'
});
```

## Hooks

    on_action = ({config}) ->
      if typeof config.modules is 'string'
        config.modules = [config.modules]: true

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'load':
            type: 'boolean'
            default: true
            description: '''
            Load the module with `modprobe`.
            '''
          'modules':
            oneOf: [
              type: 'string'
            ,
              type: 'object'
              patternProperties:
                '.*': type: 'boolean'
              additionalProperties: false
            ]
            description: '''
            Names of the modules.
            '''
          'persist':
            type: 'boolean'
            default: true
            description: '''
            Load the module on startup by placing a file, see `target`.
            '''
          'target':
            type: 'string'
            description: '''
            Path of the file to write the module, relative to
            "/etc/modules-load.d" unless absolute, default to
            "/etc/modules-load.d/{config.modules}.conf".
            '''
        required: ['modules']

## Handler

    handler = ({metadata, config}) ->
      for module, active of config.modules
        target = config.target
        target ?= "#{module}.conf"
        target = path.resolve '/etc/modules-load.d', target
        await @execute
          $if: config.load and active
          command: """
          lsmod | grep #{module} && exit 3
          modprobe #{module}
          """
          code_skipped: 3
        await @execute
          $if: config.load and not active
          command: """
          lsmod | grep #{module} || exit 3
          modprobe -r #{module}
          """
          code_skipped: 3
        await @file
          $if: config.persist
          target: target
          match: ///^#{quote module}(\n|$)///mg
          replace: if active then "#{module}\n" else ''
          append: true
          eof: true
      undefined

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions
        argument_to_config: 'modules'

## Dependencies

    path = require 'path'
    quote = require 'regexp-quote'
