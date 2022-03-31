utils = require '@nikitajs/core/lib/utils'

module.exports = {
  ...utils
  cgconfig: require './cgconfig'
  tmpfs: require './tmpfs'
}
