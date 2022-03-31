
module.exports = ({options}, callback) ->
  setImmediate =>
    @log "Hello #{options.who or 'world'}"
    callback null, true
