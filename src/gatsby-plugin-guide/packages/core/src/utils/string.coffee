
module.exports =
    escapeshellarg: (arg) ->
      result = arg.replace /'/g, (match) -> '\'"\'"\''
      "'#{result}'"
    ###
    `string.hash(file, [algorithm], callback)`
    ------------------------------------------
    Output the hash of a supplied string in hexadecimal
    form. The default algorithm to compute the hash is md5.
    ###
    hash: (data, algorithm) ->
      if arguments.length is 1
        algorithm = 'md5'
      crypto.createHash(algorithm).update(data).digest('hex')
    repeat: (str, l) ->
      Array(l+1).join str
    ###
    `string.endsWith(search, [position])`
    -------------------------------------
    Determines whether a string ends with the characters of another string,
    returning true or false as appropriate.
    This method has been added to the ECMAScript 6 specification and its code
    was borrowed from [Mozilla](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/endsWith)
    ###
    endsWith: (str, search, position) ->
      position = position or str.length
      position = position - search.length
      lastIndex = str.lastIndexOf search
      return lastIndex isnt -1 and lastIndex is position
    lines: (str) ->
      str.split /\r\n|[\n\r\u0085\u2028\u2029]/g
    max: (str, max) ->
      if str.length > max
      then str.slice(0, max) + '…'
      else str
    print_time: (time) ->
      if time > 1000*60
        "#{time / 1000}m"
      if time > 1000
        "#{time / 1000}s"
      else
        "#{time}ms"
    snake_case: (str) ->
      str.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/[-\s]+/g, '_').toLowerCase()

# nunjucks = require 'nunjucks/src/environment'
crypto = require 'crypto'
