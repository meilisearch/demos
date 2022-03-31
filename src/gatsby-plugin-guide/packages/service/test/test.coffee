
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

nikita = require '@nikitajs/core/lib'
they = require('mocha-they')(config.ssh)

they 'cache to avoid timeout later', ({ssh}) ->
  @timeout 0
  nikita($ssh: ssh).execute '''
  if command -v yum; then
    yum update -y
    yum check-update -q
  fi
  '''
