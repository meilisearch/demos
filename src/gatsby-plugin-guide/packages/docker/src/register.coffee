
# Registration of `nikita.docker` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  docker:
    build: '@nikitajs/docker/src/build'
    compose:
      '': '@nikitajs/docker/src/compose'
      up: '@nikitajs/docker/src/compose'
    cp: '@nikitajs/docker/src/cp'
    exec: '@nikitajs/docker/src/exec'
    inspect: '@nikitajs/docker/src/inspect'
    kill: '@nikitajs/docker/src/kill'
    load: '@nikitajs/docker/src/load'
    pause: '@nikitajs/docker/src/pause'
    pull: '@nikitajs/docker/src/pull'
    restart: '@nikitajs/docker/src/restart'
    rm: '@nikitajs/docker/src/rm'
    rmi: '@nikitajs/docker/src/rmi'
    run: '@nikitajs/docker/src/run'
    save: '@nikitajs/docker/src/save'
    start: '@nikitajs/docker/src/start'
    stop: '@nikitajs/docker/src/stop'
    tools:
      checksum: '@nikitajs/docker/src/tools/checksum'
      execute: '@nikitajs/docker/src/tools/execute'
      service: '@nikitajs/docker/src/tools/service'
      status: '@nikitajs/docker/src/tools/status'
    # unpause: '@nikitajs/docker/src/unpause'
    volume_create: '@nikitajs/docker/src/volume_create'
    volume_rm: '@nikitajs/docker/src/volume_rm'
    wait: '@nikitajs/docker/src/wait'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
