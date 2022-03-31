
nikita = require '@nikitajs/core/lib'
require '@nikitajs/lxd/src/register'
require '@nikitajs/log/src/register'

module.exports = ({params}) ->
  nikita
    $debug: params.debug
  .log.cli pad: host: 20, header: 60
  .log.md basename: 'start', basedir: params.log, archive: false, $if: params.log
  .execute
    cwd: "#{__dirname}/../../../assets"
    command: '''
    vagrant halt
    '''
