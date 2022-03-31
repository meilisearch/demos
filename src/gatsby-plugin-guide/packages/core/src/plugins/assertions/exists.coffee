
session = require '../../session'
utils = require '../../utils'
{mutate} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/assertions/exists'
  require: [
    '@nikitajs/core/src/plugins/metadata/raw'
    '@nikitajs/core/src/plugins/metadata/disabled'
  ]
  hooks:
    'nikita:normalize':
      # This is hanging, no time for investigation
      # after: [
      #   '@nikitajs/core/src/plugins/assertions'
      # ]
      handler: (action, handler) ->
        # Ventilate assertions properties defined at root
        assertions = {}
        for property, value of action.metadata
          if /^(un)?assert_exists$/.test property
            throw Error 'ASSERTION_DUPLICATED_DECLARATION', [
              "Property #{property} is defined multiple times,"
              'at the root of the action and inside assertions'
            ] if assertions[property]
            value = [value] unless Array.isArray value
            assertions[property] = value
            delete action.metadata[property]
        ->
          action = await handler.call null, ...arguments
          mutate action.assertions, assertions
          action
    'nikita:result': ({action, error, output}) ->
      final_run = true
      for k, v of action.assertions
        continue unless handlers[k]?
        local_run = await handlers[k].call null, action
        final_run = false if local_run is false
      throw utils.error 'NIKITA_INVALID_ASSERTION', [
        'action did not validate the assertion'
      ] unless final_run

handlers =
  assert_exists: (action) ->
    final_run = true
    for assertion in action.assertions.assert_exists
      run = await session
        $bastard: true
        $parent: action
        $raw_output: true
      , ({parent}) ->
        {exists} = await @fs.base.exists target: assertion
        exists
      final_run = false if run is false
    final_run
  unassert_exists: (action) ->
    final_run = true
    for assertion in action.assertions.unassert_exists
      run = await session
        $bastard: true
        $parent: action
        $raw_output: true
      , ->
        {exists} = await @fs.base.exists target: assertion
        exists
      final_run = false if run is true
    final_run
