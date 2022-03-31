
module.exports =
  stringify: (mode) ->
    if typeof mode is 'number' then mode.toString(8) else mode
  ###
  Compare multiple mode. All arguments modes must match. If first mode is any array, then
  other arguments mode must much at least one element of the array.
  ###
  compare: (modes...) ->
    ref = modes[0]
    throw Error "Invalid mode: #{ref}" unless ref?
    ref = [ref] unless Array.isArray ref
    ref = ref.map (mode) => @stringify mode
    for i in [1...modes.length]
      mode = @stringify modes[i]
      return false unless ref.some (m) ->
        l = Math.min m.length, mode.length
        m.substr(-l) is mode.substr(-l)
    true
