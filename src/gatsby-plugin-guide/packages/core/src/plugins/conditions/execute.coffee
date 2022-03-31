
session = require '../../session'

module.exports =
  name: '@nikitajs/core/src/plugins/conditions/execute'
  require: [
    '@nikitajs/core/src/plugins/conditions'
  ]
  hooks:
    'nikita:action':
      after: '@nikitajs/core/src/plugins/conditions'
      before: '@nikitajs/core/src/plugins/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        if not final_run
          action.metadata.disabled = true

handlers =
  if_execute: (action, value) ->
    final_run = true
    for condition in action.conditions.if_execute
      try
        {$status} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        ,
          condition
        final_run = false unless $status
      catch err
        code_skipped = condition.code_skipped or condition.config?.code_skipped
        throw err if code_skipped and parseInt(code_skipped, 10) isnt err.exit_code
        final_run = false
    final_run
  unless_execute: (action) ->
    final_run = true
    for condition in action.conditions.unless_execute
      try
        {$status} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        ,
          condition
        final_run = false if $status
      catch err
        code_skipped = condition.code_skipped or condition.config?.code_skipped
        throw err if code_skipped and parseInt(code_skipped, 10) isnt err.exit_code
    final_run
