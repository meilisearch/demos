
fs = require 'fs'
# Write default configuration
if not process.env['NIKITA_TEST_MODULE'] and (
  not fs.existsSync("#{__dirname}/../test.js") and
  not fs.existsSync("#{__dirname}/../test.json") and
  not fs.existsSync("#{__dirname}/../test.coffee")
)
  config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
  fs.writeFileSync "#{__dirname}/../test.coffee", config
# Read configuration
config = require process.env['NIKITA_TEST_MODULE'] or "../test.coffee"
# Export configuration
module.exports = config

# Cache container and vm images

return unless config.tags.lxd
nikita = require '@nikitajs/core/lib'
they = require('mocha-they')(config.config)

they 'cache container image to avoid timeout later', ({ssh}) ->
  @timeout 0
  nikita
    $ssh: ssh
  .execute
    command: "lxc image copy images:#{config.images.alpine} `lxc remote get-default`:"

return unless config.tags.lxd_vm
they 'cache vm image to avoid timeout later', ({ssh}) ->
  @timeout 0
  nikita
    $ssh: ssh
  .execute
    command: "lxc image copy images:#{config.images.alpine} `lxc remote get-default`: --vm"
  # It takes time to retrieve files from a VM image archive the first
  # time after downloading. It is way faster for a container image, so
  # we don't need it.
  .execute
    command: """
    lxc info vm1 >/dev/null && exit 42
    echo "" | lxc init images:#{config.images.alpine} vm1 --vm
    lxc rm -f vm1
    """
    code_skipped: 42
