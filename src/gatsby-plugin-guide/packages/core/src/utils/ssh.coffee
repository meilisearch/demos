
{merge} = require 'mixme'
{whoami} = require './os'

module.exports = ssh =
  compare: (ssh1, ssh2) ->
    # Between 2 configurations
    compare_config = (config1, config2) ->
      config1 and config2 and
      config1.host is config2.host and
      (config1.port or 22) is (config2.port or 22) and
      config1.username is config2.username
    return true if not ssh1 and not ssh2 and !!ssh1 is !!ssh2 # 2 null
    config1 = if ssh.is ssh1 then ssh1.config else merge ssh1
    config2 = if ssh.is ssh2 then ssh2.config else merge ssh2
    config1.username ?= whoami()
    config2.username ?= whoami()
    compare_config config1, config2
  is: (ssh) ->
    return false unless ssh?._sshstream?.config?.ident?
    /SSH-\d+.\d+-ssh2js\d+.\d+.\d+/.test ssh._sshstream.config.ident
