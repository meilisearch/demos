
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file', ->
  
  describe 'schema and validation', ->
    
    they 'check for empty replace if no source and no content', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/check_replace"
          content: 'a\nb\nc'
        await @file
          target: "#{tmpdir}/check_replace"
          match: 'b'
          replace: ''
        @file
          target: "#{tmpdir}/check_replace"
          match: 'b'
          replace: null
        .should.be.rejectedWith
          message: 'Missing source or content or replace or write'

  describe 'config `content`', ->
  
    they 'is a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'Hello'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'Hello'

    they 'is a function', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: ({config}) -> 'Hello'
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'Hello'

    they 'status is false if content is the same', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'original content'
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/file"
          content: 'new content'
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/file"
          content: 'new content'
        .should.be.finally.containEql $status: false

    they 'with source is a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_source"
          content: 'Hello'
        @file
          target: "#{tmpdir}/a_target"
          source: "#{tmpdir}/a_source"
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/a_target"
          source: "#{tmpdir}/a_source"
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_source"
          content: 'Hello'
        @fs.assert
          target: "#{tmpdir}/a_target"
          content: 'Hello'

    they 'empty file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: ''
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: ''

    they 'override empty file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/empty_file"
          content: ''
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/empty_file"
          content: ''
        @file
          target: "#{tmpdir}/empty_file"
          content: 'toto'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/empty_file"
          content: 'toto'

    they 'handle integer type', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 123
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: '123'

    they 'create parent directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a/missing/dir/a_file"
          content: 'hello'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/a/missing/dir/a_file"
          content: 'hello'

    they 'skip empty lines', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a/missing/dir/a_file"
          content: 'hello\r\nworld'
          remove_empty_lines: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/a/missing/dir/a_file"
          content: 'hello\rworld'

  describe 'config `link', ->

    they 'follow link by default', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          content: 'ko'
          target: "#{tmpdir}/target"
        @fs.link
          source: "#{tmpdir}/target"
          target: "#{tmpdir}/link"
        @file
          content: 'ok'
          target: "#{tmpdir}/link"
        @fs.assert
          target: "#{tmpdir}/target"
          content: 'ok'
        @fs.assert
          target: "#{tmpdir}/link"
          content: 'ok'

    they 'throw error if link is a directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/target"
        @fs.link
          source: "#{tmpdir}/target"
          target: "#{tmpdir}/link"
        @file
          content: 'ok'
          target: "#{tmpdir}/link"
        .should.be.rejectedWith code: 'NIKITA_FS_CRS_TARGET_EISDIR'

    they 'dont follow link if option "unlink"', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          content: 'ko'
          target: "#{tmpdir}/a_target"
        @fs.link
          source: "#{tmpdir}/a_target"
          target: "#{tmpdir}/a_link"
        @file
          content: 'ok'
          target: "#{tmpdir}/a_link"
          unlink: true
        @fs.assert
          target: "#{tmpdir}/a_target"
          content: 'ko'
        @fs.assert
          target: "#{tmpdir}/a_link"
          content: 'ok'

    they 'dont follow link if option "unlink" and link is directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir
          target: "#{tmpdir}/target"
        @fs.link
          source: "#{tmpdir}/target"
          target: "#{tmpdir}/link"
        @file
          content: 'ok'
          target: "#{tmpdir}/link"
          unlink: true
        @fs.assert
          target: "#{tmpdir}/link"
          content: 'ok'
          filetype: 'file'
        @fs.assert
          target: "#{tmpdir}/target"
          filetype: 'directory'

  describe 'ownerships and permissions', ->

    they 'set permission', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'ok'
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0700

    they 'does not modify parent', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.mkdir
          target: "#{tmpdir}/a_dir"
          mode: 0o0744
        @file
          target: "#{tmpdir}/a_file"
          content: 'ok'
          mode: 0o0700
        @fs.assert
          target: "#{tmpdir}/a_dir"
          mode: 0o0744
      
    they 'ensure mode is preserved on content update', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          mode: 0o0755
        @file
          target: "#{tmpdir}/file"
          content: "hello nikita"
        @fs.assert
          target: "#{tmpdir}/file"
          mode: 0o0755

    they 'change permission', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'ok'
          mode: 0o0700
        @file
          target: "#{tmpdir}/a_file"
          content: 'ok'
          mode: 0o0705
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/a_file"
          content: 'ok'
          mode: 0o0705
        .should.be.finally.containEql $status: false

    they 'change permission after modification', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'Hello'
          mode: 0o0700
        @file
          target: "#{tmpdir}/a_file"
          content: 'World'
          mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0755

  describe 'config `from` and `to`', ->
  
    they 'with from and with to', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          $ssh: ssh
          target: "#{tmpdir}/fromto.md"
          from: '# from'
          to: '# to'
          content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
          replace: 'my friend'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\n# from\nmy friend\n# to\nyou coquin'

    they 'with from and with to append', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nyou coquin'
        @file
          target: "#{tmpdir}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my friend'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nyou coquin\n# from\nmy friend\n# to'
        @file
          target: "#{tmpdir}/fromto.md"
          from: '# from'
          to: '# to'
          append: true
          replace: 'my best friend'
          eof: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nyou coquin\n# from\nmy best friend\n# to\n'

    they 'with from and without to', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          from: '# from'
          content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
          replace: 'my friend'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\n# from\nmy friend'

    they 'without from and with to', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          to: '# to'
          content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
          replace: 'my friend'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"

  describe 'config `replace`', ->
  
    they 'without match and place_before a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nyou+coquin'
          replace: 'my friend'
          place_before: 'you+coquin' # Regexp must escape the plus sign
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nmy friend\nyou+coquin'
  
    they 'without match and place_before a regexp', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nyou coquin'
          replace: 'my friend'
          place_before: /^you coquin$/m
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nmy friend\nyou coquin'

  describe 'config `match` & `replace`', ->
  
    they 'with match a line as a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          match: 'lets try to replace that one'
          content: 'here we are\nlets try to replace that one\nyou coquin'
          replace: 'my friend'
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/fromto.md"
          match: 'my friend'
          replace: 'my friend'
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'here we are\nmy friend\nyou coquin'
  
    they 'with match a word as a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/fromto.md"
          match: 'replace'
          content: 'replace that one\nand\nreplace this one\nand not this one'
          replace: 'switch'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/fromto.md"
          content: 'switch that one\nand\nswitch this one\nand not this one'
  
    they 'with match as a regexp', ({ssh}) ->
      # With a match
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/replace"
          content: 'email=david(at)adaltas(dot)com\nusername=root'
          match: /(username)=(.*)/
          replace: '$1=david (was $2)'
        .should.be.finally.containEql $status: true
        @file # Without a match
          target: "#{tmpdir}/replace"
          match: /this wont work/
          replace: '$1=david (was $2)'
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/replace"
          content: 'email=david(at)adaltas(dot)com\nusername=david (was root)'

    they 'with match as a regexp and multiple content', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          match: /(.*try) (.*)/
          content: 'here we are\nlets try to replace that one\nyou coquin'
          replace: ['my friend, $1']
          target: "#{tmpdir}/replace"
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/replace"
          content: 'here we are\nmy friend, lets try\nyou coquin'

    they 'with match as a regexp on line and empty string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          append: true
          content: 'aaa\nmatch\nccc\nmatch'
          eof: true
          match: /^match(\n|$)/mg
          replace: ''
          target: "#{tmpdir}/replace"
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/replace"
          content: 'aaa\nccc\n'

    they 'with match with global and multilines', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/replace"
          match: /^property=.*$/mg
          content: '#A config file\n#property=30\nproperty=10\nproperty=20\n#End of Config'
          replace: 'property=50'
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/replace"
          match: /^property=50$/mg
          replace: 'property=50'
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/replace"
          content: '#A config file\n#property=30\nproperty=50\nproperty=50\n#End of Config'

    they 'will replace target if source or content does not exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'This is\nsome content\nfor testing'
        @file
          target: "#{tmpdir}/a_file"
          match: /(.*content)/
          replace: 'a text'
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/a_file"
          match: /(.*content)/
          replace: 'a text'
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'This is\na text\nfor testing'

  describe 'config `place_before`', ->

    they 'is true, prepend the content', ({ssh}) ->
      # File doesnt exists, creates one
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'world'
          place_before: true
        @file # File exists, prepends to it
          target: "#{tmpdir}/a_file"
          replace: 'hello'
          place_before: true
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'hello\nworld'

  describe 'config `append`', ->

    they 'append content to missing file', ({ssh}) ->
      # File does not exist, it creates it with the content
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'hello'
          append: true
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'hello'

    they 'append content to existing file', ({ssh}) ->
      # File does not exists, it create one
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'hello'
          append: true
        @file # File exists, it append to it
          target: "#{tmpdir}/a_file"
          content: 'world'
          append: true
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'helloworld'

  describe 'config `match` and `append` or `place_before`', ->

    describe 'will not prepend/append if match', ->

      they 'place_before true, replace a string, match a regexp', ({ssh}) ->
        # Prepare by creating a file with content
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'you coquin\nhere we are\n'
          @file
            target: "#{tmpdir}/file"
            match: /.*coquin/
            replace: 'new coquin'
            place_before: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'new coquin\nhere we are\n'
          # Write a second time with same match
          @file
            target: "#{tmpdir}/file"
            match: /.*coquin/
            replace: 'new coquin'
            place_before: true
          .should.be.finally.containEql $status: false
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'new coquin\nhere we are\n'

      they 'place_before true, replace a string, match a string', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'you coquin\nhere we are\n'
          @file
            target: "#{tmpdir}/file"
            match: "you coquin"
            replace: 'new coquin'
            place_before: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'new coquin\nhere we are\n'
          # Write a second time with same match
          @file
            target: "#{tmpdir}/file"
            match: "new coquin"
            replace: 'new coquin'
            place_before: true
          .should.be.finally.containEql $status: false
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'new coquin\nhere we are\n'

      they 'place_after', ({ssh}) ->
        # Prepare by creating a file with content
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\n'
          @file
            target: "#{tmpdir}/file"
            match: /.*coquin/
            replace: 'new coquin'
            append: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'here we are\nnew coquin\n'
          # Write a second time with same match
          @file
            target: "#{tmpdir}/file"
            match: /.*coquin/
            replace: 'new coquin'
            append: true
          .should.be.finally.containEql $status: false
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'here we are\nnew coquin\n'

    they 'will append if no match', ({ssh}) ->
      # Prepare by creating a file with content
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'here we are\nyou coquin\n'
        @file
          target: "#{tmpdir}/file"
          match: /will never work/
          replace: 'Add this line'
          append: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'here we are\nyou coquin\nAdd this line'

    describe 'config `place_before`/`place_after` a match if it is a regexp', ->

      they 'place_before', ({ssh}) ->
        # Prepare by creating a file with content
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\nshould we\nhave fun'
          @file
            target: "#{tmpdir}/file"
            match: /will never work/
            replace: 'Add this line'
            place_before: /^.*we.*$/m
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'Add this line\nhere we are\nyou coquin\nshould we\nhave fun'

      they 'place_after', ({ssh}) ->
        # Prepare by creating a file with content
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\nshould we\nhave fun'
          @file
            target: "#{tmpdir}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/m
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'here we are\nAdd this line\nyou coquin\nshould we\nhave fun'

    describe 'config `place_before`/`place_after` multiple times if regexp with global flag', ->

      they 'place_before', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\nshould we\nhave fun'
          @file
            target: "#{tmpdir}/file"
            match: /will never work/
            replace: 'Add this line'
            place_before: /^.*we.*$/gm
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'Add this line\nhere we are\nyou coquin\nAdd this line\nshould we\nhave fun'

      they 'place_after', ({ssh}) ->
        # Prepare by creating a file with content
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\nshould we\nhave fun'
          @file
            target: "#{tmpdir}/file"
            match: /will never work/
            replace: 'Add this line'
            append: /^.*we.*$/gm
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'

    they 'will append place_after a match if append is a string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'here we are\nyou coquin\nshould we\nhave fun'
        @file
          target: "#{tmpdir}/file"
          match: /will never work/
          replace: 'Add this line'
          append: 'we'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'here we are\nAdd this line\nyou coquin\nshould we\nAdd this line\nhave fun'

    describe 'will detect new line if no match', ->

      they 'place_before', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin'
          @file
            target: "#{tmpdir}/file"
            match: /will never be found/
            replace: 'Add this line'
            place_before: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'Add this line\nhere we are\nyou coquin'

      they 'place_after', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin'
          @file
            target: "#{tmpdir}/file"
            match: /will never be found/
            replace: 'Add this line'
            append: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'here we are\nyou coquin\nAdd this line'

    describe 'create file if not exists', ->

      they 'place_before', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            match: /will never be found/
            replace: 'Add this line'
            place_before: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'Add this line'

      they 'place_after', ({ssh}) ->
        nikita
          $ssh: ssh
          $tmpdir: true
        , ({metadata: {tmpdir}}) ->
          @file
            target: "#{tmpdir}/file"
            match: /will never be found/
            replace: 'Add this line'
            append: true
          .should.be.finally.containEql $status: true
          @fs.assert
            target: "#{tmpdir}/file"
            content: 'Add this line'

    they 'match is optional', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/a_file"
          content: 'Here we are\nyou coquin'
        @file
          target: "#{tmpdir}/a_file"
          replace: 'Add this line'
          append: true
        .should.be.finally.containEql $status: true
        @file
          target: "#{tmpdir}/a_file"
          replace: 'Add this line'
          append: true
        .should.be.finally.containEql $status: false
        @file
          target: "#{tmpdir}/a_file"
          write: [
            replace: 'Add this line'
            append: true
          ]
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'Here we are\nyou coquin\nAdd this line'

  describe 'config `backup`', ->
  
    they 'create a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'Hello'
        @file
          target: "#{tmpdir}/file"
          content: 'Hello'
          backup: '.bck'
        .should.be.finally.containEql $status: false
        @fs.assert
          target: "#{tmpdir}/file.bck"
          not: true
        @file
          target: "#{tmpdir}/file"
          content: 'Hello Node'
          backup: '.bck'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file.bck"
          content: 'Hello'

    they 'a non-existing file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'Hello'
          backup: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'Hello'

    they 'with specific permissions', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/new_file_perm"
          content: 'Hello World'
        @file
          target: "#{tmpdir}/new_file_perm"
          content: 'Hello'
          mode: 0o0644
          backup: '.bck1'
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/new_file_perm.bck1"
          content: 'Hello World'
          mode: 0o0400
        @file
          target: "#{tmpdir}/new_file_perm"
          content: 'Hello World'
          backup: '.bck2'
          mode: 0o0644
          backup_mode: 0o0640
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/new_file_perm.bck2"
          content: 'Hello'
          mode: 0o0640

  describe 'config `write`', ->
  
    they 'do multiple replace', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'username: me\nemail: my@email\nfriends: you'
        @file
          target: "#{tmpdir}/file"
          write: [
            match: /^(username).*$/m
            replace: "$1: you"
          ,
            match: /^email.*$/m
            replace: ""
          ,
            match: /^(friends).*$/m
            replace: "$1: me"
          ]
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'username: you\n\nfriends: me'
  
    they 'use append', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'username: me\nfriends: you'
        @file
          target: "#{tmpdir}/file"
          write: [
            match: /^(username).*$/m
            replace: "$1: you"
          ,
            match: /^email.*$/m
            replace: "email: your@email"
            append: 'username'
          ,
            match: /^(friends).*$/m
            replace: "$1: me"
          ]
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'username: you\nemail: your@email\nfriends: me'
  
    they 'handle partial match', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'username: me\nfriends: none'
        @file
          target: "#{tmpdir}/file"
          write: [
            match: /^will never match$/m
            replace: "useless"
          ,
            match: /^email.*$/m
            replace: "email: my@email"
            append: 'username'
          ,
            match: /^(friends).*$/m
            replace: "$1: you"
          ]
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'username: me\nemail: my@email\nfriends: you'

  describe 'error', ->

    they 'can not define source and content', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: 'abc'
          source: 'abc'
          content: 'abc'
        .should.be.rejectedWith message: 'Define either source or content'

    they 'if source doesn\'t exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          source: "#{tmpdir}/does/not/exists"
        .should.be.rejectedWith message: "Source does not exist: \"#{tmpdir}/does/not/exists\""

    they 'if local source doesn\'t exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          source: "#{tmpdir}/does/not/exists"
          local: true
        .should.be.rejectedWith message: "Source does not exist: \"#{tmpdir}/does/not/exists\""

  describe 'config `eof`', ->

    they 'auto-detected', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'this is\r\nsome content'
          eof: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'this is\r\nsome content\r\n'

    they 'not detected', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          $ssh: ssh
          target: "#{tmpdir}/file"
          content: 'this is some content'
          eof: true
        .should.be.finally.containEql $status: true
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'this is some content\n'

  describe 'config `transform`', ->

    they 'transform content status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            "#{config.content} world"
        .should.be.finally.containEql $status: true

    they 'transform content value', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            "#{config.content} world"
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'hello world'

    they 'transform resolve promise status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ->
            new Promise (resolve, reject) ->
              resolve('hello')
        .should.be.finally.containEql $status: true

    they 'transform resolve promise value', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ->
            new Promise (resolve, reject) ->
              resolve('hello world')
        @fs.assert
          target: "#{tmpdir}/file"
          content: 'hello world'

    they 'transform reject promise status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ->
            new Promise (resolve, reject) ->
              reject('nope')
        .should.be.rejectedWith undefined

    they 'transform reject promise value', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ->
            new Promise (resolve, reject) ->
              reject()
        @fs.assert
          target: "#{tmpdir}/file"
          not: true

    they 'transform returns null status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            null
        .should.be.finally.containEql $status: false

    they 'transform returns null file doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            null
        @fs.assert
          target: "#{tmpdir}/file"
          not: true

    they 'transform returns undefined status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            undefined
        .should.be.finally.containEql $status: false

    they 'transform returns undefined file doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            undefined
        @fs.assert
          target: "#{tmpdir}/file"
          not: true
        
    they 'transform throws error', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          target: "#{tmpdir}/file"
          content: 'hello'
          transform: ({config}) ->
            throw Error('error')
        .should.be.rejectedWith 'error'

  describe 'config `target`', ->

    they 'catch error', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          content: 'hello'
          target: ({content: content}) ->
            throw Error content
        .should.be.rejectedWith 'hello'

    they 'function called on content change', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file
          content: 'hello'
          eof: true
          target: ({content: content}) ->
            content.should.eql 'hello\n'
