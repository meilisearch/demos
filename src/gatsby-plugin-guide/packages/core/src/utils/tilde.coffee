
tilde = require 'tilde-expansion'
path = require 'path'

###
Not, those function are not aware of an SSH connection
and can't use `path.posix` when appropriate over SSH.
It could be assumed that a path starting with `~` is 
always posix but this is not yet handled and tested.
###

module.exports =
  normalize: (location) ->
    new Promise (accept, reject) ->
      tilde location, (location) ->
        accept path.normalize location
  resolve: (locations...) ->
    normalized = for location in locations
      module.exports.normalize location
    normalized = await Promise.all normalized
    path.resolve ...normalized
