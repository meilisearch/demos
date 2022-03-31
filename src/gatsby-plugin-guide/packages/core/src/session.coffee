
{merge} = require 'mixme'
registry = require './registry'
schedule = require './schedulers'
plugandplay = require 'plug-and-play'
contextualize = require './session/contextualize'
normalize = require './session/normalize'
utils = require './utils'

session = (args, options={}) ->
  # Catch calls to new actions
  namespace = []
  on_call = (...args) ->
    # Extract action namespace and reset the state
    [namespace, nm] = [[], namespace]
    # Schedule the action and get the result as a promise
    prom = action.scheduler.push ->
      # Validate the namespace
      child = await action.registry.get nm
      unless child
        return Promise.reject utils.error 'ACTION_UNREGISTERED_NAMESPACE', [
          'no action is registered under this namespace,'
          "got #{JSON.stringify nm}."
        ]
      args_is_array = args.some (arg) -> Array.isArray arg
      if not args_is_array or child.metadata?.raw_input then return session args,
        namespace: nm
        child: child
        parent: action
      # Multiply the arguments
      schedule strict: true, paused: true, utils.array.multiply(...args).map (args) -> ->
        session args,
          namespace: nm
          child: child
          parent: action
    new Proxy prom, get: on_get
  # Building the namespace before calling an action
  on_get = (target, name) ->
    if target[name]? and not action.registry.registered name
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    if namespace.length is 0
      switch name
        when 'plugins' then return action.plugins
    namespace.push name
    new Proxy on_call, get: on_get
  # Initialize the plugins manager
  options.parent = options.parent or args[0]?.$parent or undefined
  options.namespace = options.namespace or args[0]?.$namespace or undefined
  plugins = plugandplay
    plugins: options.plugins or args[0]?.$plugins or args[0]?.plugins
    chain: new Proxy on_call, get: on_get
    parent: if options.parent then options.parent.plugins else undefined
  # Normalize arguments
  action = plugins.call_sync
    name: 'nikita:arguments'
    plugins: options.plugins
    args: {args: args, ...options}
    handler: ({args, namespace}) ->
      contextualize [...args, $namespace: namespace]
  action.parent = options.parent
  action.plugins = plugins
  action.scheduler ?= {}
  action.metadata.namespace ?= []
  # Initialize the registry to manage action registration
  action.registry = registry.create
    plugins: action.plugins
    parent: if action.parent then action.parent.registry else registry
    on_register: (name, act) ->
      await action.plugins.call
        name: 'nikita:register'
        args: name: name, action: act
  # Local scheduler to execute children and be notified on finish
  schedulers =
    in: schedule()
    out: schedule null, strict: true, paused: true
  action.scheduler = schedulers.out
  # Expose the action context
  action.context = new Proxy on_call, get: on_get
  # Execute the action
  result = new Promise (resolve, reject) ->
    # Hook intented to modify the current action being created
    try
      action = await action.plugins.call
        name: 'nikita:normalize'
        args: action
        hooks: action.hooks?.on_normalize or action.on_normalize
        handler: normalize
    catch err
      schedulers.out.end err
      return reject err
    # Load action from registry
    if action.metadata.namespace
      action_from_registry = await action.registry.get action.metadata.namespace
      # Merge the registry action with the user action properties
      for k, v of action_from_registry
        action[k] = merge action_from_registry[k], action[k]
    # Switch the scheduler to register actions inside the handler
    action.scheduler = schedulers.in
    # Hook attended to alter the execution of an action handler
    output = action.plugins.call
      name: 'nikita:action'
      args: action
      hooks: action.hooks.on_action
      handler: (action) ->
        # Execution of an action handler
        action.handler.call action.context, action
    # Ensure child actions are executed
    pump = ->
      action.scheduler.resume()
      null
    output.then pump, pump
    # Make sure the promise is resolved after the scheduler and its children
    Promise.all [output, action.scheduler]
    .then ([output]) ->
      schedulers.out.resume()
      await schedulers.out
      output
    .then (output) ->
      on_result undefined, output
    , (err) ->
      schedulers.out.end err
      on_result err
    # Hook to catch error and format output once all children are executed
    on_result = (error, output) ->
      action.plugins.call
        name: 'nikita:result'
        args: action: action, error: error, output: output
        hooks: action.hooks.on_result
        handler: ({action, error, output}) ->
          if error then throw error else output
      .then resolve, reject
  result.then (output) ->
    return unless action.parent is undefined
    action.plugins.call
      name: 'nikita:resolved'
      args: action: action, output: output
  , (err) ->
    return unless action.parent is undefined
    action.plugins.call
      name: 'nikita:rejected'
      args: action: action, error: err
  # Returning a proxified promise:
  # - new actions can be registered to it as long as the promised has not fulfilled
  # - resolve when all registered actions are fulfilled
  # - resolved with the result of handler
  new Proxy result, get: on_get

module.exports = (...args) ->
  session args

module.exports.with_options = (args, options) ->
  session args, options
