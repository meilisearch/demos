
# Partial

Replace partial elements in a text.

    module.exports = (config, log) ->
      return unless config.write?.length
      log message: "Replacing sections of the file", level: 'DEBUG'
      for opts in config.write
        if opts.match
          opts.match ?= opts.replace
          log message: "Convert match string to regexp", level: 'DEBUG' if typeof opts.match is 'string'
          opts.match = ///#{utils.regexp.quote opts.match}///mg if typeof opts.match is 'string'
          throw Error "Invalid match option, got #{JSON.stringify opts.match} instead of a RegExp" unless opts.match instanceof RegExp
          if opts.match.test config.content
            config.content = config.content.replace opts.match, opts.replace
            log message: "Match existing partial", level: 'INFO'
          else if opts.place_before and typeof opts.replace is 'string'
            if typeof opts.place_before is "string"
              opts.place_before = new RegExp ///^.*#{utils.regexp.quote opts.place_before}.*$///mg
            if opts.place_before instanceof RegExp
              log message: "Replace with match and place_before regexp", level: 'DEBUG'
              posoffset = 0
              orgContent = config.content
              while (res = opts.place_before.exec orgContent) isnt null
                log message: "Before regexp found a match", level: 'INFO'
                pos = posoffset + res.index #+ res[0].length
                config.content = config.content.slice(0,pos) + opts.replace + '\n' + config.content.slice(pos)
                posoffset += opts.replace.length + 1
                break unless opts.place_before.global
              place_before = false
            else# if content
              log message: "Forgot how we could get there, test shall say it all", level: 'DEBUG'
              linebreak = if config.content.length is 0 or config.content.substr(config.content.length - 1) is '\n' then '' else '\n'
              config.content = opts.replace + linebreak + config.content
          else if opts.append and typeof opts.replace is 'string'
            if typeof opts.append is "string"
              log message: "Convert append string to regexp", level: 'DEBUG'
              opts.append = new RegExp "^.*#{utils.regexp.quote opts.append}.*$", 'mg'
            if opts.append instanceof RegExp
              log message: "Replace with match and append regexp", level: 'DEBUG'
              posoffset = 0
              orgContent = config.content
              while (res = opts.append.exec orgContent) isnt null
                log message: "Append regexp found a match", level: 'INFO'
                pos = posoffset + res.index + res[0].length
                config.content = config.content.slice(0,pos) + '\n' + opts.replace + config.content.slice(pos)
                posoffset += opts.replace.length + 1
                break unless opts.append.global
            else
              linebreak = if config.content.length is 0 or config.content.substr(config.content.length - 1) is '\n' then '' else '\n'
              config.content = config.content + linebreak + opts.replace
          else
            continue # Did not match, try callback
        else if opts.place_before is true
          log message: "Before is true, need to explain how we could get here", level: 'INFO'
        else if opts.from or opts.to
          if opts.from and opts.to
            from = ///(^#{utils.regexp.quote opts.from}$)///m.exec(config.content)
            to = ///(^#{utils.regexp.quote opts.to}$)///m.exec(config.content)
            if from? and not to?
              log message: "Found 'from' but missing 'to', skip writing", level: 'WARN'
            else if not from? and to?
              log message: "Missing 'from' but found 'to', skip writing", level: 'WARN'
            else if not from? and not to?
              if opts.append
                config.content += '\n' + opts.from + '\n' + opts.replace+ '\n' + opts.to
              else
                log message: "Missing 'from' and 'to' without append, skip writing", level: 'WARN'
            else
              config.content = config.content.substr(0, from.index + from[1].length + 1) + opts.replace + '\n' + config.content.substr(to.index)
          else if opts.from and not opts.to
            from = ///(^#{utils.regexp.quote opts.from}$)///m.exec(config.content)
            if from?
              config.content = config.content.substr(0, from.index + from[1].length) + '\n' + opts.replace
            else # TODO: honors append
              log message: "Missing 'from', skip writing", level: 'WARN'
          else if not opts.from and opts.to
            from_index = 0
            to = ///(^#{utils.regexp.quote opts.to}$)///m.exec(config.content)
            if to?
              config.content = opts.replace + '\n' + config.content.substr(to.index)
            else # TODO: honors append
              log message: "Missing 'to', skip writing", level: 'WARN'

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
