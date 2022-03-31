---
navtitle: Contribute
description: How to contribute to the project
sort: 4
---

# Contributing

Nikita is an open source project hosted on [GitHub](https://github.com/adaltas/node-nikita) originally written by [Adaltas](https://www.adaltas.com).

Contributions go far beyond pull requests and commits. we are thrilled to receive a variety of other contributions including the following:

- Write and publish your own actions
- Write articles and blog posts, create a tutorial, and spread the words
- Submit new ideas of features and documentation
- Submitting documentation updates, enhancements, designs, or bugfixes
- Submitting spelling or grammar fixes
- Additional unit or functional tests
- Help to answer questions and issues on GitHub

## Open Development

All work on Nikita happens directly on GitHub. Both core team members and external contributors send pull requests which go through the same review process.

## Branch Organization

We will do our best to keep the master branch in good shape, with tests passing at all times. But in order to move fast, we will make API changes that your application might not be compatible with. We recommend that you use the latest stable version of Nikita.

If you send a pull request, please do it against the master branch. We maintain stable branches for major versions separately but we don’t accept pull requests to them directly. Instead, we cherry-pick non-breaking changes from master to the latest stable major version.

## Semantic Versioning

Nikita follows [Semantic Versioning](https://semver.org/) (aka SemVer). We release patch versions for bug fixes, minor versions for new features, and major versions for any breaking changes. When we make breaking changes, we also introduce deprecation warnings in a minor version so that our users learn about the upcoming changes and migrate their code in advance.

Every significant change is documented in the [Changelog](/project/changelog/) file.

## Documentation

Managing an open source project a huge time sink and most of us are non-native English speakers. We greatly appreciate any time spent fixing typos or clarifying sections in the documentation.

## Discussions

There is currently no channel dedicated to discussing Nikita. For now, you may simply [open a new issue](https://github.com/adaltas/node-nikita/issues/new).

## Proposing a Change

### Pull requests

If you intend to change the public API or make any non-trivial changes to the implementation, we recommend [filing an issue](https://github.com/adaltas/node-nikita/issues/new). This lets us reach an agreement on your proposal before you put significant effort into it.

If you’re only fixing a bug, it’s fine to submit a pull request right away but we still recommend filing an issue detailing what you’re fixing. This is helpful in case we don’t accept that specific fix but want to keep track of the issue.

### Conventional Commits

The Nikita Git repository follows the [Conventional Commits](https://www.conventionalcommits.org) specification that provides an easy set of rules for creating an explicit commit history.

Here's how a commit message looks like:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The `<type>` message follows [the Angular convention](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit) and must be one from the list: `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`. The `[optional scope]` message is associated to the directory name of [the available packages](https://github.com/adaltas/node-nikita/tree/master/packages). A scope is optional and is contained within parentheses, e.g., `feat(engine): ability to parse arrays`. Follow [the specification](https://www.conventionalcommits.org) to learn more about Conventional Commits.

Commit messages are automatically validated, in case of any mistake the error message is prompted. Internally, we use [Husky](https://typicode.github.io/husky/) which plugs into Git by registering a hook to call [commitlint](https://commitlint.js.org/) to validate the format of the messages.

## Bugs

### Where to Find Known Issues

We are using GitHub Issues for our public bugs. We keep a close eye on this and try to make it clear when we have an internal fix in progress. Before filing a new task, try to make sure your problem doesn’t already exist.

### Reporting New Issues

The best way to get your bug fixed is to provide a reduced test case. You can get inspiration from our current [tests' suite](https://github.com/adaltas/node-nikita/tree/master/packages/core/test). Note, tests are filtered by tags and some tests require a specific environment which is provided through [Docker or LXD environments](https://github.com/adaltas/node-nikita/tree/master/packages/tools/env).
