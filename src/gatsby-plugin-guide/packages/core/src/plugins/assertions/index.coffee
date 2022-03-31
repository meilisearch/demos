
session = require '../../session'
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/assertions'
  require: [
    '@nikitajs/core/src/plugins/metadata/raw'
    '@nikitajs/core/src/plugins/metadata/disabled'
  ]
  hooks:
    'nikita:normalize': (action, handler) ->
      # Ventilate assertions properties defined at root
      assertions = {}
      for property, value of action.metadata
        if /^(un)?assert$/.test property
          throw Error 'ASSERTION_DUPLICATED_DECLARATION', [
            "Property #{property} is defined multiple times,"
            'at the root of the action and inside assertions'
          ] if assertions[property]
          value = [value] unless Array.isArray value
          assertions[property] = value
          delete action.metadata[property]
      ->
        action = await handler.call null, ...arguments
        action.assertions = assertions
        action
    'nikita:result': ({action, error, output}) ->
      final_run = true
      for k, v of action.assertions
        continue unless handlers[k]?
        local_run = await handlers[k].call null, action, error, output
        final_run = false if local_run is false
      throw utils.error 'NIKITA_INVALID_ASSERTION', [
        'action did not validate the assertion'
      ] unless final_run

handlers =
  assert: (action, error, output) ->
    final_run = true
    for assertion in action.assertions.assert
      if typeof assertion is 'function'
        run = await session
          $:
            handler: assertion
            metadata:
              bastard: true
              raw_output: true
            parent: action
            config: action.config
            error: error
            output: output
        throw utils.error 'NIKITA_ASSERTION_INVALID_OUTPUT', [
          'invalid assertion output,'
          'expect a boolean value,'
          "got #{JSON.stringify run}."
        ] unless typeof run is 'boolean'
      else
        run = utils.object.match output, assertion
      final_run = false if run is false
    final_run
  unassert: (action, error, output) ->
    final_run = true
    for assertion in action.assertions.unassert
      if typeof assertion is 'function'
        run = await session
          $:
            handler: assertion
            metadata:
              bastard: true
              raw_output: true
            parent: action
            config: action.config
            error: error
            output: output
        throw utils.error 'NIKITA_ASSERTION_INVALID_OUTPUT', [
          'invalid assertion output,'
          'expect a boolean value,'
          "got #{JSON.stringify run}."
        ] unless typeof run is 'boolean'
      else
        run = utils.object.match output, assertion
      final_run = false if run is true
    final_run
