
module.exports = ({config}) ->
  @lxc.stop
    $header: 'Container stop'
    container: "#{config.container}"
