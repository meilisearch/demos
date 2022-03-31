
module.exports = who: 'me', author: 'me', handler: ({options}, callback) ->
  setImmediate =>
    @log "Hello #{options.who or 'world'}"
    callback null, true
