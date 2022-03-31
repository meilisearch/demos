# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# [1.0.0-alpha.2](https://github.com/adaltas/node-nikita/compare/@nikitajs/lxd@1.0.0-alpha.1...@nikitajs/lxd@1.0.0-alpha.2) (2021-08-30)


### Bug Fixes

* log dependency declarations ([0469f05](https://github.com/adaltas/node-nikita/commit/0469f05d0ef5d3675f21bbd260b2dcfe94bfa3a7))


### Features

* **lxd:** add list actions for instances and networks ([97927bc](https://github.com/adaltas/node-nikita/commit/97927bcc0fb495098a26e8d36bc6cc66dda654e4))
* **lxd:** add stop and delete actions to lxc.cluster ([0b94441](https://github.com/adaltas/node-nikita/commit/0b944419c6b8918e085a00ae02ee90e80b9a8c3e))
* **lxd:** replace ip with native ipv4.address ([49137f8](https://github.com/adaltas/node-nikita/commit/49137f857d59e8acfdc22c2a53819ff7e30ea6cb))
* **lxd:** schema migration ([058ec1e](https://github.com/adaltas/node-nikita/commit/058ec1ec3faefed3b75e29f98f4b689b2c5005aa))
* **lxd:** support for apk and rc in cluster ([cb2da1c](https://github.com/adaltas/node-nikita/commit/cb2da1cf5c7c7f4f72e83bded982278192530ad1))





# [1.0.0-alpha.1](https://github.com/adaltas/node-nikita/compare/@nikitajs/lxd@1.0.0-alpha.0...@nikitajs/lxd@1.0.0-alpha.1) (2021-03-10)


### Bug Fixes

* **lxd:** openssl status in cluster ([e206c18](https://github.com/adaltas/node-nikita/commit/e206c1828721d5fb51904426ee5dea5c2c9f5885))


### Features

* **lxd:** argument to config in delete ([d19391b](https://github.com/adaltas/node-nikita/commit/d19391b99672493a35e6822aabf7953020318bd9))
* **lxd:** argument to config in storage delete ([9a6763a](https://github.com/adaltas/node-nikita/commit/9a6763a5224b5c7622106af3cac7b24d5a9b7aeb))
* **lxd:** exec.cwd config ([0d3d7f4](https://github.com/adaltas/node-nikita/commit/0d3d7f415da5f9524daec925ba87a88023b0f2f6))
* **lxd:** exec.user config ([8019f8a](https://github.com/adaltas/node-nikita/commit/8019f8a20def0481d3e9389a699461abd78d6255))
* **lxd:** openssl install with apt in cluster ([d706807](https://github.com/adaltas/node-nikita/commit/d706807c3d81aca1335e64199f112b4239f78dae))
* **lxd:** option env in exec ([5a904b0](https://github.com/adaltas/node-nikita/commit/5a904b0a7c174619ee78cb39a6cb71878a385301))
* schema coercion ([9e52391](https://github.com/adaltas/node-nikita/commit/9e52391852a8e45b35674faa44f17747303b2851))





# [1.0.0-alpha.0](https://github.com/adaltas/node-nikita/compare/@nikitajs/lxd@0.9.7...@nikitajs/lxd@1.0.0-alpha.0) (2021-02-03)

The jump to version 1.0.0 is a major which rewrite every single part of the code. The list of changes is too big to be reproduced here. We'll start generating the changelog from this version.

## Trunk

New features:
lxd: start/stop cluster log

## 0.9.6

New features:
* lxd.exec: reduce collision risk in heredoc
* lxd.show: new action
* lxd.cluster: refactor cli
* lxd: validate container name
* lxd: import cluster code
* lxd.exec: enforce trap
* lxd.goodies.prlimit: print container limits
* file.cache: new cookies option
* lxd.config.set: implement new action
* lxd.config.set: new action
* lxd.config.device.exists: new action
* lxd.running: new action
* lxd: added network actions
* lxd.stop: new action
* lxd.start: new action

Cleanup:
* package: simplify test command
