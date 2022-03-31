
utils = require '@nikitajs/core/lib/utils'

module.exports = {
  ...utils
  iptables: require './iptables'
}
