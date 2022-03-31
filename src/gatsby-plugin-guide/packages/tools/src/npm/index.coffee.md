
# `nikita.tools.npm`

Install Node.js packages with NPM.

It upgrades outdated packages if config "upgrade" is "true".

## Example

The following action installs the coffescript package globally.

```js
const {$status} = await nikita.tools.npm({
  name: 'coffeescript',
  global: true
})
console.info(`Package was installed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'cwd':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/cwd'
          'global':
            type: 'boolean'
            default: false
            description: '''
            Installs the current package context as a global package.
            '''
          'name':
            type: 'array', items: type: 'string'
            description: '''
            Name of the package(s) to install or upgrade if config "upgrade" is
            "true".
            '''
          'sudo':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/sudo'
          'upgrade':
            default: false
            type: 'boolean'
            description: '''
            Upgrade outdated packages.
            '''
        required: ['name']
        if: properties: 'global': const: false
        then: required: ['cwd']

## Handler

    handler = ({config, tools: {log}}) ->
      # Upgrade
      await @tools.npm.upgrade
        $if: config.upgrade
        cwd: config.cwd
        global: config.global
        name: config.name
      # Get installed packages
      {packages} = await @tools.npm.list
        cwd: config.cwd
        global: config.global
      # Install packages
      installed = Object.keys packages
      install = for name in config.name
        continue if installed.includes name.split('@')[0]
        name
      return unless install.length
      await @execute
        command: [
          'npm install'
          '--global' if config.global
          ...install
        ].join ' '
        cwd: config.cwd
      log message: "NPM Installed Packages: #{install.join ', '}"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'name'
        definitions: definitions
