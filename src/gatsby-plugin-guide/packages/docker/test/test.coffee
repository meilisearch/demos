
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

# Cache images
return unless config.tags.docker
nikita = require '@nikitajs/core/lib'
they = require('mocha-they')(config.config)
they 'wait for docker daemon to listen', ({ssh}) ->
  # Note, this particularly apply to docker compose environnements
  # where the daemon take some time to be up and running
  # Wait 10s before timeout
  # It takes some time under heavy load like testing in parallel
  nikita
    $ssh: ssh
    docker: config.docker
  # .execute.wait
  #   command: 'docker ps'
  #   retry: 40
  #   interval: 250
  .docker.tools.execute
    $interval: 1000 # nor interval nor sleep seems implemented
    $retry: 40
    command: 'ps'
they 'cache image to avoid timeout later', ({ssh}) ->
  @timeout 0
  nikita
    $ssh: ssh
    docker: config.docker
  .docker.pull image: 'httpd'
