
ini = require 'ini'
utils = require '@nikitajs/core/lib/utils'

module.exports =
  # Remove undefined and null values
  safe: (val) ->
    if ( typeof val isnt "string" or val.match(/[\r\n]/) or val.match(/^\[/) or (val.length > 1 and val.charAt(0) is "\"" and val.slice(-1) is "\"") or val isnt val.trim() )
    then JSON.stringify(val)
    else val.replace(/;/g, '\\;')

  dotSplit: `function (str) {
    return str.replace(/\1/g, '\2LITERAL\\1LITERAL\2')
           .replace(/\\\./g, '\1')
           .split(/\./).map(function (part) {
             return part.replace(/\1/g, '\\.')
                    .replace(/\2LITERAL\\1LITERAL\2/g, '\1')
           })
  }`
  parse: (content, options) ->
    ini.parse content
  # parse: (str, options={}) ->
  #   TODO: braket level might be good, to parse sub curly sub levels
  #   shall be delegated to `parse_brackets_then_curly` like its
  #   stringify counterpart is doing
  #   lines = require('@nikitajs/core/lib/misc/string').lines str
  #   current = data = {}
  #   stack = [current]
  #   comment = options.comment or ';'
  #   lines.forEach (line, _, __) ->
  #     return if not line or line.match(/^\s*$/)
  #     # Category level 1
  #     if match = line.match /^\s*\[(.+?)\]\s*$/
  #       keys = match[1].split '.'
  #       depth = keys.length
  #       # Create intermediate levels if they dont exist
  #       d = data
  #       if depth > 1 then for i in keys[0...keys.length]
  #         throw Error "Invalid Key: #{keys[i]}" if data[keys[i]]? and not typeof data[keys[i]] is 'object'
  #         d[keys[i]] ?= {}
  #         d = d[keys[i]]
  #       # if depth > 1 then for i in [0 ... depth]
  #       #   stack.push {}
  #       # Add a child
  #       if depth is stack.length
  #         parent = stack[depth - 1]
  #         parent[match[1]] = current = {}
  #         stack.push current
  #       # Move to parent or at the same level
  #       else if depth is stack.length - 1
  #         stack.splice depth, stack.length - depth
  #         parent = stack[depth - 1]
  #         parent[match[1]] = current = {}
  #         stack.push current
  #       # Invalid child hierarchy
  #       else
  #         throw Error "Invalid child #{match[1]}"
  #     else if match = line.match /^\s*(.+?)\s*=\s*\{\s*$/
  #       throw Error "Invalid Depth: inferior to 2, got #{depth}" if depth < 2
  #       # Add a child
  #       parent = stack[stack.length - 1]
  #       parent[match[1]] = current = {}
  #       stack.push current
  #     else if match = line.match /^\s*\}\s*$/
  #       throw Error "Invalid Depth: inferior to 2, got #{depth}" if depth < 2
  #       stack.pop()
  #     # comment
  #     else if comment and match = line.match ///^\s*(#{comment}.*)$///
  #       current[match[1]] = null
  #     # key value
  #     else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
  #       if textmatch = match[2].match /^"(.*)"$/
  #         match[2] = textmatch[1].replace '\\"', '"'
  #       current[match[1]] = match[2]
  #     # else
  #     else if match = line.match /^\s*(.+?)\s*$/
  #       current[match[1]] = null
  #   data
  parse_brackets_then_curly: (str, options={}) ->
    lines = utils.string.lines str
    current = data = {}
    stack = [current]
    comment = options.comment or ';'
    lines.forEach (line, _, __) ->
      return if not line or line.match(/^\s*$/)
      # Category level 1
      if match = line.match /^\s*\[(.+?)\]\s*$/
        key = match[1]
        current = data[key] = {}
        stack = [current]
      else if match = line.match /^\s*(.+?)\s*=\s*\{\s*$/
        # Add a child
        parent = stack[stack.length - 1]
        parent[match[1]] = current = {}
        stack.push current
      else if match = line.match /^\s*\}\s*$/
        throw Error "Invalid Syntax: found extra \"}\"" if stack.length is 0
        stack.pop()
        current = stack[stack.length - 1]
      # comment
      else if comment and match = line.match ///^\s*(#{comment}.*)$///
        current[match[1]] = null
      # key value
      else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
        if textmatch = match[2].match /^"(.*)"$/
          match[2] = textmatch[1].replace '\\"', '"'
        current[match[1]] = match[2]
      # else
      else if match = line.match /^\s*(.+?)\s*$/
        current[match[1]] = null
    data
  ###
  
  Each category is surrounded by one or several square brackets. The number of brackets indicates
  the depth of the category.
  Options are

  *   `comment`   Default to ";"

  ###
  parse_multi_brackets: (str, options={}) ->
    lines = utils.string.lines str
    current = data = {}
    stack = [current]
    comment = options.comment or ';'
    lines.forEach (line, _, __) ->
      return if not line or line.match(/^\s*$/)
      # Category
      if match = line.match /^\s*(\[+)(.+?)(\]+)\s*$/
        depth = match[1].length
        # Add a child
        if depth is stack.length
          parent = stack[depth - 1]
          parent[match[2]] = current = {}
          stack.push current
        # Invalid child hierarchy
        if depth > stack.length
          throw Error "Invalid child #{match[2]}"
        # Move up or at the same level
        if depth < stack.length
          stack.splice depth, stack.length - depth
          parent = stack[depth - 1]
          parent[match[2]] = current = {}
          stack.push current
      # comment
      else if comment and match = line.match ///^\s*(#{comment}.*)$///
        current[match[1]] = null
      # key value
      else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
        current[match[1]] = match[2]
      # else
      else if match = line.match /^\s*(.+?)\s*$/
        current[match[1]] = null
    data
  ###
  Same as the parse_multi_brackets instead it takes in count values which are defined on several lines
  As an example the ambari-agent .ini configuration file

  *   `comment`   Default to ";"

  ###
  parse_multi_brackets_multi_lines: (str, options={}) ->
    lines = utils.string.lines str
    current = data = {}
    stack = [current]
    comment = options.comment or ';'
    writing = false
    previous = {}
    lines.forEach (line, _, __) ->
      return if not line or line.match(/^\s*$/)
      # Category
      if match = line.match /^\s*(\[+)(.+?)(\]+)\s*$/
        depth = match[1].length
        # Add a child
        if depth is stack.length
          parent = stack[depth - 1]
          parent[match[2]] = current = {}
          stack.push current
        # Invalid child hierarchy
        if depth > stack.length
          throw Error "Invalid child #{match[2]}"
        # Move up or at the same level
        if depth < stack.length
          stack.splice depth, stack.length - depth
          parent = stack[depth - 1]
          parent[match[2]] = current = {}
          stack.push current
      # comment
      else if comment and match = line.match ///^\s*(#{comment}.*)$///
        writing = false
        current[match[1]] = null
      # key value
      else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
        writing = false
        current[match[1]] = match[2]
        previous = match[1]
        writing = true
      # else
      else if match = line.match /^\s*(.+?)\s*$/
        if writing
          current[previous] += match[1]
        else
          current[match[1]] = null
    data
  # same as ini parse but transform value which are true and type of true as ''
  # to be user by stringify_single_key
  stringify: (obj, section, options={}) ->
    if arguments.length is 2
      options = section
      section = undefined
    options.separator ?= ' = '
    options.eol ?= if not options.ssh and process.platform is "win32" then "\r\n" else "\n"
    options.escape ?= true
    safe = module.exports.safe
    dotSplit = module.exports.dotSplit
    children = []
    out = ""
    Object.keys(obj).forEach (k, _, __) ->
      val = obj[k]
      if val and Array.isArray val
        val.forEach (item) ->
          out += safe("#{k}[]") + options.separator + safe(item) + options.eol
      else if val and typeof val is "object"
        children.push k
      else if typeof val is 'boolean'
        if val is true
          out += safe(k) + options.eol
        else
          # disregard false value
      else
        out += safe(k) + options.separator + safe(val) + options.eol
    if section and out.length
      out = "[" + safe(section) + "]" + options.eol + out
    children.forEach (k, _, __) ->
      # escape the section name dot as some daemon could not parse it
      nk = if options.escape then dotSplit(k).join '\\.'  else k
      child = module.exports.stringify(obj[k], (if section then section + "." else "") + nk, options)
      if out.length and child.length
        out += options.eol
      out += child
    out
  # works like stringify but write only the key when the value is ''
  # be careful when using ini.parse is parses single key line as key = true
  stringify_single_key: (obj, section, options={}) ->
    if arguments.length is 2
      options = section
      section = undefined
    options.separator ?= ' = '
    options.eol ?= if not options.ssh and process.platform is "win32" then "\r\n" else "\n"
    safe = module.exports.safe
    dotSplit = module.exports.dotSplit
    children = []
    out = ""
    Object.keys(obj).forEach (k, _, __) ->
      val = obj[k]
      if val and Array.isArray val
        val.forEach (item) ->
          out += if val is '' or val is true then "#{k}" + "\n" else safe("#{k}[]") + options.separator + safe(item) + "\n"
      else if val and typeof val is "object"
        children.push k
      else
        out += if val is '' or val is true then "#{k}" + options.eol else safe(k) + options.separator + safe(val) + options.eol
    if section and out.length
      out = "[" + safe(section) + "]" + options.eol + out
    children.forEach (k, _, __) ->
      nk = dotSplit(k).join '\\.'
      child = module.exports.stringify_single_key(obj[k], (if section then section + "." else "") + nk, options)
      if out.length and child.length
        out += options.eol
      out += child
    out
  stringify_square_then_curly: (content, depth=0, options={}) ->
    console.error 'Deprecated Function: use stringify_brackets_then_curly instead of stringify_square_then_curly'
    module.exports.stringify_brackets_then_curly content, depth, options
  stringify_brackets_then_curly: (content, depth=0, options={}) ->
    if arguments.length is 2
      options = depth
      depth = 0
    options.separator ?= ' = '
    options.eol ?= if not options.ssh and process.platform is "win32" then "\r\n" else "\n"
    out = ''
    indent = ' '
    prefix = ''
    for i in [0...depth]
      prefix += indent
    for k, v of content
      # isUndefined = typeof v is 'undefined'
      isBoolean = typeof v is 'boolean'
      isNull = v is null
      isArray = Array.isArray v
      isObj = typeof v is 'object' and not isNull and not isArray
      if isObj
        if depth is 0
          out += "#{prefix}[#{k}]#{options.eol}"
          out += module.exports.stringify_brackets_then_curly v, depth + 1, options
          out += "#{options.eol}"
        else
          out += "#{prefix}#{k}#{options.separator}{#{options.eol}"
          out += module.exports.stringify_brackets_then_curly v, depth + 1, options
          out += "#{prefix}}#{options.eol}"
      else
        if isArray
          outa = []
          for element in v
            outa.push "#{prefix}#{k}#{options.separator}#{element}"
          out += outa.join "#{options.eol}"
        else if isNull
          out += "#{prefix}#{k}#{options.separator}null"
        else if isBoolean
          out += "#{prefix}#{k}#{options.separator}#{if v then 'true' else 'false'}"
        else
          out += "#{prefix}#{k}#{options.separator}#{v}"
        out += "#{options.eol}"
    out
  ###
  Each category is surrounded by one or several square brackets. The number of brackets indicates
  the depth of the category.
  Taking now indent option into consideration: some file are indent aware ambari-agent .ini file
  ###
  stringify_multi_brackets: (content, depth=0, options={}) ->
    if arguments.length is 2
      options = depth
      depth = 0
    options.separator ?= ' = '
    options.eol ?= if not options.ssh and process.platform is "win32" then "\r\n" else "\n"
    out = ''
    indent = if options.indent? then options.indent else '  '
    prefix = ''
    for i in [0...depth]
      prefix += indent
    for k, v of content
      isBoolean = typeof v is 'boolean'
      isNull = v is null
      isArray = Array.isArray v
      isObj = typeof v is 'object' and not isArray and not isNull
      continue if isObj
      if isNull
        out += "#{prefix}#{k}"
      else if isBoolean
        out += "#{prefix}#{k}#{options.separator}#{if v then 'true' else 'false'}"
      else if isArray
        out += v
        .filter (vv) -> vv?
        .map (vv) ->
          throw Error "Stringify Invalid Value: expect a string for key #{k}, got #{vv}" unless typeof vv is 'string'
          "#{prefix}#{k}#{options.separator}#{vv}"
        .join options.eol
      else
        out += "#{prefix}#{k}#{options.separator}#{v}"
      out += "#{options.eol}"
    for k, v of content
      isNull = v is null
      isArray = Array.isArray v
      isObj = typeof v is 'object' and not isArray and not isNull
      continue unless isObj
      # out += "#{prefix}#{utils.string.repeat '[', depth+1}#{k}#{utils.string.repeat ']', depth+1}#{options.eol}"
      out += "#{prefix}#{'['.repeat depth+1}#{k}#{']'.repeat depth+1}#{options.eol}"
      out += module.exports.stringify_multi_brackets v, depth + 1, options
    out
