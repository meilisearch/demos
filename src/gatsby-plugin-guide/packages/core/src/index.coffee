
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

require './register'
session = require './session'
  
create = (...args) ->
  session.with_options args, plugins: [
    require './plugins/args'
    require './plugins/metadata/argument_to_config'
    require './plugins/assertions'
    require './plugins/assertions/exists'
    require './plugins/conditions'
    require './plugins/conditions/execute'
    require './plugins/conditions/exists'
    require './plugins/conditions/os'
    require './plugins/execute'
    require './plugins/global'
    require './plugins/history'
    require './plugins/magic_dollar'
    require './plugins/metadata/debug'
    require './plugins/metadata/disabled'
    require './plugins/metadata/header'
    require './plugins/metadata/position'
    require './plugins/metadata/raw'
    require './plugins/metadata/relax'
    require './plugins/metadata/retry'
    require './plugins/metadata/schema'
    require './plugins/metadata/tmpdir'
    require './plugins/metadata/uuid'
    require './plugins/output/logs'
    require './plugins/output/status'
    require './plugins/pubsub'
    require './plugins/ssh'
    require './plugins/time'
    require './plugins/templated'
    require './plugins/tools/dig'
    require './plugins/tools/events'
    require './plugins/tools/find'
    require './plugins/tools/log'
    require './plugins/tools/path'
    require './plugins/tools/schema'
    require './plugins/tools/walk'
  ]

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
