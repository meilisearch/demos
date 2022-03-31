
class NikitaError extends Error
  constructor: (code, message, ...contexts) ->
    message = message
    .filter (line) -> !!line
    .join(' ') if Array.isArray message
    message = "#{code}: #{message}"
    super message
    if Error.captureStackTrace
      Error.captureStackTrace this, NikitaError
    this.code = code
    for context in contexts
      for key of context
        continue if key is 'code'
        value = context[key]
        continue if value is undefined
        this[key] = if Buffer.isBuffer value
        then value.toString()
        else if value is null
        then value
        else JSON.parse JSON.stringify value

module.exports = ->
  new NikitaError ...arguments

module.exports.got = (value, {depth = 0, max_depth = 3} = {}) ->
  switch typeof value
    when 'function'
      'function'
    when 'object'
      if Array.isArray value
        out = []
        for _, el of value
          if depth is max_depth
            out.push '\u2026'
          else
            out.push module.exports.got el, depth: depth+1, max_depth: max_depth
        "[#{out.join ','}]"
      else
        JSON.stringify value
    else
      JSON.stringify value
