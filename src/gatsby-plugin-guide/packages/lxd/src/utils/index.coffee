
utils = require '@nikitajs/core/lib/utils'

module.exports = {
  ...utils
  stderr_to_error_message: require './stderr_to_error_message'
}
