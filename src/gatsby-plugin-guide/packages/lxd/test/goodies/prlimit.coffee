
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd_prlimit

describe 'lxc.goodie.prlimit', ->

  they 'stdout', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-goodies-prlimit-1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-goodies-prlimit-1'
        start: true
      try
        await @lxc.goodies.prlimit
          container: 'nikita-goodies-prlimit-1'
      catch err
        throw err unless err.code is 'NIKITA_LXC_PRLIMIT_MISSING'
