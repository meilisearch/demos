
utils = require '../utils'

###
Usage:
schedule([handlers], [options])
schedule([options], [handlers])
Options:
- strict
  Task failure prevent any additionnal task to be executed and close the
  scheduler.
- paused
  Prevent the execution of newly registered tasks, call resume to trigger the
  execution.
###

module.exports = (handlers, options) ->
  if Array.isArray(handlers) or handlers? is false
    options ?= {}
  else if typeof handlers is 'object' and (Array.isArray(options) or options? is false)
    opts = options
    options = handlers
    handlers = opts
  else
    throw Error 'Invalid arguments'
  # Options normalisation
  options.strict ?= false
  options.paused ?= false
  # Internal usage
  stack = []
  scheduler = null
  state =
    paused: options.paused
    output: []
    resolved: false
    running: false
  promise = new Promise (resolve, reject) ->
    scheduler =
      pause: ->
        state.paused = true
      resume: ->
        state.paused = false
        scheduler.pump()
      end: (err, output) ->
        state.resolved = true
        if err
          while task = stack.shift()
            task.reject err
          return reject err
        else
          resolve output
      pump: ->
        return if state.running
        unless state.resolved
          unless stack.length
            return this.end null, state.output
        return unless stack.length
        state.running = true
        item = stack.shift()
        item = item
        setImmediate ->
          try
            result = await item.handler.call()
            state.running = false
            item.resolve.call null, result
            # Include tasks output in the scheduler promise
            # Default to only the tasks provide at initialisation
            # Use the push output option to include additionnal tasks
            state.output.push result if item.options.output
            setImmediate -> scheduler.pump()
          catch error
            state.running = false
            item.reject.call null, error
            if options.strict
            then scheduler.end error 
            else setImmediate -> scheduler.pump()
      unshift: (handlers, options={}) ->
        options.pump ?= true
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        new Promise (resolve, reject) ->
          unless isArray
            stack.unshift
              handler: handlers
              resolve: resolve
              reject: reject
              options: options
            scheduler.pump() unless state.paused
          else
            # Unshift from the last to the first element to preserve order
            Promise.all((
              scheduler.unshift handler, pump: false for handler in handlers.reverse()
            ).reverse()).then resolve, reject
      push: (handlers, options={}) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        prom = new Promise (resolve, reject) ->
          unless isArray
            stack.push
              handler: handlers
              resolve: resolve
              reject: reject
              options: options
            scheduler.pump() unless state.paused
          else
            Promise.all(
              scheduler.push handler, options for handler in handlers
            ).then resolve, reject
        prom.catch (->) # Handle strict unhandled rejections
        prom
    if handlers
      if handlers.length
        scheduler.push handlers, output: true
        scheduler.pump()
      else
        resolve []
  promise.catch (->) # Handle strict unhandled rejections
  new Proxy promise, get: (target, name) ->
    if target[name]?
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    else
      scheduler[name]
