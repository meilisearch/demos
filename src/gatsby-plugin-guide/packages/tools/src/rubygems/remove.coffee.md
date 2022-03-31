
# `nikita.tools.rubygems.remove`

Remove a Ruby gem.

Ruby Gems package a ruby library with a common layout. Inside gems are the 
following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec   

## Output

* `$status`   
  Indicate if a gem was removed.

## Ruby behavior

Ruby place global gems inside "/usr/share/gems/gems" and user gems are by 
default installed inside "/usr/local/share/gems".

Any attempt to remove a gem installed globally and not in the user repository 
will result with the error "{gem} is not installed in GEM_HOME, try: gem 
uninstall -i /usr/share/gems json"

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'gem_bin':
            type: 'string'
            default: 'gem'
            description: '''
            Path to the gem command.
            '''
          'name':
            type: 'string'
            description: '''
            Name of the gem, required.
            '''
          'version':
            type: 'string'
            description: '''
            Version of the gem.
            '''
        required: ['name']

## Handler

    handler = ({config}) ->
      # Global config
      config.ruby ?= {}
      config[k] ?= v for k, v of config.ruby
      config.gem_bin ?= 'gem'
      version = if config.version then "-v #{config.version}" else '-a'
      gems = null
      await @execute
        command: """
        #{config.gem_bin} list -i #{config.name} || exit 3
        #{config.gem_bin} uninstall #{config.name} #{version}
        """
        code_skipped: 3
        bash: config.bash

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ruby'
        definitions: definitions
