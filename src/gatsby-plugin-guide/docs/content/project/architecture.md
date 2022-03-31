---
navtitle: Architecture
sort: 3
---

# Project architecture

Nikita is a Node.js based software use to automate the execution of actions. Use an already defined action or write one in JavaScript. If you are interested to read the Nikita codebase, this page presents the high-level architecture of the project. Use it as a map to find what thing is doing what accross the code, where is it located.

## Project layout

Nikita is organized as one [GIT monorepo](https://github.com/adaltas/node-nikita) repository. If you are not familiar with this organization, read the Adaltas series of articles on [monorepos in JavaScript](https://www.adaltas.com/en/2021/01/05/js-monorepos-project-initialization/).

All the packages are located inside the [`packages` folder](https://github.com/adaltas/node-nikita/tree/master/packages).

The documentation is located inside the [`docs/content` folder](https://github.com/adaltas/node-nikita/tree/master/docs/content) for the raw documentation written in Markdown and the [`docs/website` folder](https://github.com/adaltas/node-nikita/tree/master/docs/website) for the website generation with [Gatsby](https://www.gatsbyjs.com/).

## Project management

[Lerna](https://github.com/lerna/lerna) is used to coordinate the installation of package and execution of commands accross all the Nikita packages.

Versioning and change log generation is based on [conventionnal commit](https://www.adaltas.com/en/2021/02/02/js-monorepos-commits-changelog/).

### How packages relate to each other

The [`nikita` package](https://github.com/adaltas/node-nikita/tree/master/packages/nikita) provide an entry point for the majority of users. The [`@nikitajs/core` package](https://github.com/adaltas/node-nikita/tree/master/packages/core) is the heart of the library with its engine, the plugins and the core actions. All the other packages defines additionnal actions. For example, the [`@nikitajs/docker` package](https://github.com/adaltas/node-nikita/tree/master/packages/docker) defines Docker related actions.

### The `nikita` package

Users are encouraged to declare the `nikita` package as their only dependency. The package is just a facade in front of the `@nikitajs/core` package where the Nikita logic resides and all the other packages which defines additional actions. 

Using the `nikita` package, developers can require Nikita in their code with `const nikita = require('nikita')` and they are ready to go.

In fact, if you look inside the `nikita` package, there is only [one module](https://github.com/adaltas/node-nikita/tree/master/packages/nikita/lib) and its content is explicit:

```js
// Register actions from Nikita packages
require('@nikitajs/db/lib/register')
require('@nikitajs/docker/lib/register')
require('@nikitajs/file/lib/register')
require('@nikitajs/ipa/lib/register')
require('@nikitajs/java/lib/register')
require('@nikitajs/krb5/lib/register')
require('@nikitajs/ldap/lib/register')
require('@nikitajs/log/lib/register')
require('@nikitajs/lxd/lib/register')
require('@nikitajs/network/lib/register')
require('@nikitajs/service/lib/register')
require('@nikitajs/system/lib/register')
require('@nikitajs/tools/lib/register')
// Expose the Nikita core engine
module.exports = require('@nikitajs/core')
```

## The `@nikitajs/core` package

The package defines an entry point in [the `src/index.coffee` module](https://github.com/adaltas/node-nikita/blob/master/packages/core/src/index.coffee). The module creates a new `session` instance from [the `src/session.coffee` module](https://github.com/adaltas/node-nikita/blob/master/packages/core/src/session.coffee) with all the plugins loaded.

Plugins are stored inside the [`src/plugins` folder](https://github.com/adaltas/node-nikita/tree/master/packages/core/src/plugins). Pretty much everything in Nikita is implemented as a plugin. Plugins define hooks which are interception points of the action lifecycle.

Worth of interest are also the [`src/registry.coffee` module](https://github.com/adaltas/node-nikita/blob/master/packages/core/src/registry.coffee) to register and unregister actions and the [`src/schedulers/native.coffee` module](https://github.com/adaltas/node-nikita/blob/master/packages/core/src/schedulers/native.coffee) to control the execution of action successive actions.
