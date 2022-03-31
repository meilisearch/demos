
utils = require '@nikitajs/core/lib/utils'

module.exports = (err, stderr) ->
  stderr = stderr.trim()
  err.message = stderr if utils.string.lines(stderr).length is 1
