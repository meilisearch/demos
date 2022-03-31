
# `nikita.tools.npm.upgrade`

Upgrade all Node.js packages with NPM.

## Example

The following action upgrades all global packages.

```js
const {$status} = await nikita.tools.npm.upgrade({
  global: true
})
console.info(`Packages were upgraded: ${$status}`)
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
            Upgrades global packages.
            '''
          'name':
            type: 'array', items: type: 'string'
            description: '''
            Name of the package(s) to upgrade.
            '''
        if: properties: 'global': const: false
        then: required: ['cwd']

## Handler

    handler = ({config, tools: {log}}) ->
      # Get outdated packages
      {packages} = await @tools.npm.outdated
        cwd: config.cwd
        global: config.global
      outdated = for name, info of packages
        continue if info.current is info.wanted
        name
      if config.name
        names = config.name.map (name) -> name.split('@')[0]
        outdated = outdated
        .filter (name) -> names.includes name
      # No package to upgrade
      return unless outdated.length
      # Upgrade outdated packages
      await @execute
        command: [
          'npm'
          'update'
          '--global' if config.global
        ].join ' '
        cwd: config.cwd
      log message: "NPM upgraded packages: #{outdated.join ', '}"

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Note

From the NPM documentation:

> https://docs.npmjs.com/cli/v6/commands/npm-update#updating-globally-installed-packages
Globally installed packages are treated as if they are installed
with a caret semver range specified.

However, we didn't saw this with npm@7.5.3:

```
npm install -g csv-parse@3.0.0
npm update -g
npm ls -g csv-parse # print 4.15.1
```
