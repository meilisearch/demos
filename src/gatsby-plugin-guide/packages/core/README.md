
# Nikita "core" package

The `core` package provides the Nikita engine and the core Nikita actions and plugins.

## Documentation

The [Nikita website](https://nikita.js.org/) covers:
* The [API](https://nikita.js.org/current/api/) created by this package
* [several guides](https://nikita.js.org/current/guide/) to learn the Foundamental concepts.
* The [actions](https://nikita.js.org/current/packages/core/) registered in this package.

## Architecture

The package is composed of:

* The core engine:
  * The package entry point to instantiate Nikita sessions loaded with plugins and which register the actions present in this package.
  * The session module which is the internal engine.
  * The registry module to associate action names to modules.
  * The scheduler to orchestrate the execution of actions and their children.
  * The register script to register the package's actions.
* Foundamental actions covering:
  * Basic actions such as `assert`, `call` and `wait`.
  * Execute actions to interact with Unix commands and process.
  * SSH related actions.
  * Filesystem related actions.
* Plugins which extends Nikita in various ways such as:
  * Assertions to validate action behavior.
  * Conditions to enable and disable action execution.
  * Metadata to modify action's behaviors.
  * Tools to provide usefull data and functions to actions.

## Usage

Nikita is commonly imported by refering to the `nikita` package. However, it will load a lot of actions which are potentially not necessary. By using the `core` package directly, you reduce your dependencies and the number of modules loaded in your Node.js process.

To import the module:

```js
const nikita = require('@nikitajs/core');
```

Then, call the `register` scripts to register additionnal actions, for example the `lxd` actions:

```js
require('@nikitajs/lxd/lib/register');
```

Following this example, you can now use any action present in the `core` and the `lxd` packages:

```js
// Use the `execute` action from the `core` package
const {
  stdout: whoami
} = await nikita.execute('whoami', { trim: true });
// Use the `lxc.init` action from the `lxd` package
nikita.lxc.init({
  image: 'images:alpine/3.13',
  container: `nikita-${whoami}`
});
```
