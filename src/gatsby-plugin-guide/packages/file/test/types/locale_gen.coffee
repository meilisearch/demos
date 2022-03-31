
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.locale_gen', ->

  they 'activate locales', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/etc/locale.gen"
        content: """
        #  en_US.UTF-8 UTF-8
        #en_US.UTF-8 UTF-8
        #en_US ISO-8859-1
        #fr_FR.UTF-8 UTF-8
        #fr_FR ISO-8859-1
        #es_ES.UTF-8 UTF-8
        """
      {$status} = await @file.types.locale_gen
        target: "#{tmpdir}/etc/locale.gen"
        locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
        generate: false
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/etc/locale.gen"
        content: """
        #  en_US.UTF-8 UTF-8
        en_US.UTF-8 UTF-8
        #en_US ISO-8859-1
        fr_FR.UTF-8 UTF-8
        #fr_FR ISO-8859-1
        #es_ES.UTF-8 UTF-8
        """

  they 'desactivate locales', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/etc/locale.gen"
        content: """
        #  en_US.UTF-8 UTF-8
        en_US.UTF-8 UTF-8
        en_US ISO-8859-1
        fr_FR.UTF-8 UTF-8
        fr_FR ISO-8859-1
        es_ES.UTF-8 UTF-8
        """
      {$status} = await @file.types.locale_gen
        target: "#{tmpdir}/etc/locale.gen"
        locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
        generate: false
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/etc/locale.gen"
        content: """
        #  en_US.UTF-8 UTF-8
        en_US.UTF-8 UTF-8
        #en_US ISO-8859-1
        fr_FR.UTF-8 UTF-8
        #fr_FR ISO-8859-1
        #es_ES.UTF-8 UTF-8
        """

  they 'rootdir with default target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/etc/locale.gen"
        content: "#en_US.UTF-8 UTF-8"
      {$status} = await @file.types.locale_gen
        rootdir: "#{tmpdir}"
        locales: ['en_US.UTF-8']
        generate: false
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/etc/locale.gen"
        content: "en_US.UTF-8 UTF-8"
