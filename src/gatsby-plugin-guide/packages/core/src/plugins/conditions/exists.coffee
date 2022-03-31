
session = require '../../session'

module.exports =
  name: '@nikitajs/core/src/plugins/conditions/exists'
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
        action.metadata.disabled = true unless final_run

handlers =
  if_exists: (action, value) ->
    final_run = true
    for condition in action.conditions.if_exists
      try
        await session
          $bastard: true
          $parent: action
        , ->
          await @fs.base.stat target: condition
      catch err
        if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          final_run = false
        else throw err
    final_run
  unless_exists: (action) ->
    final_run = true
    for condition in action.conditions.unless_exists
      try
        await session
          $bastard: true
          $parent: action
        , ->
          await @fs.base.stat target: condition
        final_run = false
      catch err
        unless err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          throw err
    final_run
