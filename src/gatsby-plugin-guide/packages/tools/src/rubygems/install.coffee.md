
# `nikita.tools.rubygems.install`

Install a Ruby gem.

Ruby gems package a ruby library with a common layout. Inside gems are the 
following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

## Example

Install a gem from its name and version:

```js
const {$status} = await nikita.tools.rubygems.install({
  name: 'json',
  version: '2.1.0',
})
console.info(`Gem installed: ${$status}`)
```

Install a gem from a local file:

```js
const {$status} = await nikita.tools.rubygems.install({
  source: '/path/to/json-2.1.0.gem'
})
console.info(`Gem installed: ${$status}`)
```

Install gems from a glob expression:

```js
const {$status} = await nikita.tools.rubygems.install({
  source: '/path/to/*.gem',
})
console.info(`Gem installed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'bindir':
            type: 'string'
            description: '''
            Directory where binary files are located.
            '''
          'build_flags':
            type: 'string'
            description: '''
            Pass flags to the compiler.
            '''
          'bash':
            $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/bash'
          'gem_bin':
            type: 'string'
            default: 'gem'
            description: '''
            Path to the gem command.
            '''
          'name':
            type: 'string'
            description: '''
            Name of the gem.
            '''
          'source':
            type: 'string'
            description: '''
            Path to the gem package.
            '''
          'target':
            type: 'string'
            description: '''
            Install directory.
            '''
          'version':
            type: 'string'
            description: '''
            Version of the gem.
            '''
        required: ['name']

## Handler

    handler = ({config, ssh, tools: {path}}) ->
      # Global config
      config.ruby ?= {}
      config[k] ?= v for k, v of config.ruby
      gems = {}
      gems[config.name] ?= config.version
      # Get all current gems
      current_gems = {}
      {stdout} = await @execute
        $shy: true
        command: """
        #{config.gem_bin} list --versions
        """
        bash: config.bash
      for line in utils.string.lines stdout
        continue if line.trim() is ''
        [name, version] = line.match(/(.*?)(?:$| \((?:default:\s+)?([\d\., ]+)\))/)[1..3]
        current_gems[name] = version.split(', ')
      # Make array of sources and filter
      sources = []
      if config.source
        {files} = await @fs.glob config.source
        current_filenames = []
        for name, versions of current_gems
          for version in versions
            current_filenames.push "#{name}-#{version}.gem"
        sources = files.filter (source) ->
          filename = path.basename source
          true unless filename in current_filenames
      # Filter gems
      for name, version of gems
        # Install if Gem isnt yet there
        continue unless current_gems[name]
        # Install if a version is demanded and no installed version satisfy it
        is_version_matching = current_gems[name].some (current_version) -> semver.satisfies version, current_version
        continue if version and not is_version_matching
        delete gems[name]
      # Install from sources
      if sources.length
        await @execute
          command: (
            for source in sources
              [
                "#{config.gem_bin}"
                "install"
                "--bindir '#{config.bindir}'" if config.bindir
                "--install-dir '#{config.target}'" if config.target
                "--local '#{source}'" if source
                "--build-flags config.build_flags" if config.build_flags
              ].join ' '
            ).join '\n'
          code: [0, 2]
          bash: config.bash
      # Install from gems
      if Object.keys(gems).length
        await @execute
          command: (
            for name, version of gems
              [
                "#{config.gem_bin}"
                "install"
                "#{name}"
                "--bindir '#{config.bindir}'" if config.bindir
                "--install-dir '#{config.target}'" if config.target
                "--version '#{version}'" if version
                "--build-flags config.build_flags" if config.build_flags
              ].join ' '
            ).join '\n'
          code: [0, 2]
          bash: config.bash

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ruby'
        definitions: definitions

## Dependencies

    semver = require 'semver'
    utils = require '../utils'
