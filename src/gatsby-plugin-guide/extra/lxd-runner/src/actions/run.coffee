
module.exports = ({config}) ->
  await @call '@nikitajs/lxd-runner/lib/actions/start', config
  await @call '@nikitajs/lxd-runner/lib/actions/test', config
  await @call '@nikitajs/lxd-runner/lib/actions/stop', config
