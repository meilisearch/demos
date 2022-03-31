
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.my_cnf', ->

  they 'generate from content', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.my_cnf
        target: "#{tmpdir}/my.cnf"
        content:
          'client':
            'socket': '/var/lib/mysql/mysql.sock'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/my.cnf"
        content: """
        [client]
        socket = /var/lib/mysql/mysql.sock
        """
        trim: true
