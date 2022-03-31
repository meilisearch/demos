
# Diff

Report the difference between 2 strings.

    module.exports = (oldStr, newStr, options) ->
      oldStr ?= ''
      newStr ?= ''
      lines = diff.diffLines oldStr, newStr
      text = []
      count_added = count_removed = 0
      padsize = Math.ceil(lines.length/10)
      for line in lines
        continue if line.value is null
        if not line.added and not line.removed
          count_added++; count_removed++; continue
        ls = string.lines line.value
        if line.added
          for line in ls
            count_added++
            text.push "#{pad padsize, ''+(count_added)} + #{line}"
        else
          for line in ls
            count_removed++
            text.push "#{pad padsize, ''+(count_removed)} - #{line}"
      raw: lines, text: text.map( (t) -> "#{t}\n" ).join('')

## Dependencies

    pad = require 'pad'
    diff = require 'diff'
    string = require './string'
