
module.exports =
  # new: (stat)
  #   Stats = (stat) ->
  #     @mode = stat && stat.mode
  #     @uid = stat && stat.uid
  #     @gid = stat && stat.gid
  #     @size = stat && stat.size
  #     @atime = stat && stat.atime
  #     @mtime = stat && stat.mtime
  #   Stats.prototype._checkModeProperty = (property) ->
  #     (this.mode & constants.S_IFMT) is property
  #   Stats.prototype.isDirectory = ->
  #     @_checkModeProperty constants.S_IFDIR
  #   Stats.prototype.isFile = ->
  #     @_checkModeProperty constants.S_IFREG
  #   Stats.prototype.isBlockDevice = ->
  #     @_checkModeProperty constants.S_IFBLK
  #   Stats.prototype.isCharacterDevice = ->
  #     @_checkModeProperty constants.S_IFCHR
  #   Stats.prototype.isSymbolicLink = ->
  #     @_checkModeProperty constants.S_IFLNK
  #   Stats.prototype.isFIFO = ->
  #     @_checkModeProperty constants.S_IFIFO
  #   Stats.prototype.isSocket = ->
  #     @_checkModeProperty constants.S_IFSOCK
  isDirectory: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFDIR
  isFile: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFREG
  isBlockDevice: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFBLK
  isCharacterDevice: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFCHR
  isSymbolicLink: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFLNK
  isFIFO: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFIFO
  isSocket: (mode) ->
    (mode & constants.S_IFMT) is constants.S_IFSOCK
  type: (mode) ->
    if @isDirectory mode
      'Directory'
    else if @isFile mode
      'File'
    else if @isBlockDevice mode
      'Block Device'
    else if @isCharacterDevice mode
      'Character Device'
    else if @isSymbolicLink mode
      'Symbolic Link'
    else if @isFIFO mode
      'FIFO'
    else if @isSocket mode
      'Socket'
    else
      'Unknown'

## Dependencies

constants = require('fs').constants
