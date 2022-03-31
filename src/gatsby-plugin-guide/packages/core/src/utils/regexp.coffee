
quote = require 'regexp-quote'

module.exports =
  # Escape RegExp related charracteres
  # eg `///^\*/\w+@#{misc.regexp.escape realm}\s+\*///mg`
  escape: (str) ->
    str.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"
  is: (reg) ->
    reg instanceof RegExp
  quote: quote
