
module.exports = ({config}) ->
  @lxc.cluster
    $header: 'Container start'
  , config.cluster
