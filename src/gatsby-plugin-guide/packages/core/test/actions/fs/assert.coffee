
fs = require 'fs'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.assert', ->
  
  describe 'schema', ->
    
    it 'coersion', ->
      nikita.fs.assert
        mode: '744',
        target: '/tmp/fake'
      , ({config}) ->
        config.mode.should.eql [ 0o0744 ]
  
  describe 'exists', ->

    they 'file doesnt not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert "#{tmpdir}/a_file"
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILE_MISSING'
          message: [
            'NIKITA_FS_ASSERT_FILE_MISSING:'
            'file does not exists,'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '

    they 'file exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: ''
        @fs.assert "#{tmpdir}/a_file"
  
    they 'with config not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.assert "#{tmpdir}/a_file", not: true
        await @fs.base.writeFile "#{tmpdir}/a_file", content: ''
        @fs.assert "#{tmpdir}/a_file", not: true
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILE_EXISTS'
          message: [
            'NIKITA_FS_ASSERT_FILE_EXISTS:'
            'file exists,'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '
  
    they 'requires target', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert
          content: "are u here"
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
    they 'send custom error message', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert
          target: "#{tmpdir}/a_file"
          error: 'Got it'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILE_MISSING'
          message: 'Got it'
  
  describe 'config `filetype`', ->
  
    they 'assert a file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: ''
        await @fs.assert
          target: "#{tmpdir}/a_file"
          filetype: 'file'
        await @fs.assert
          target: "#{tmpdir}/a_file"
          filetype: fs.constants.S_IFREG
        @fs.assert
          target: "#{tmpdir}"
          filetype: 'file'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILETYPE_INVALID'
          message: [
            'NIKITA_FS_ASSERT_FILETYPE_INVALID: filetype is invalid,'
            'expect "File" type, got "Directory" type,'
            "location is \"#{tmpdir}\"."
          ].join ' '
  
    they 'assert a directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.assert
          target: "#{tmpdir}"
          filetype: 'directory'
        await @fs.assert
          target: "#{tmpdir}"
          filetype: fs.constants.S_IFDIR
        await @fs.base.writeFile "#{tmpdir}/a_file", content: ''
        @fs.assert
          target: "#{tmpdir}/a_file"
          filetype: 'directory'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_FILETYPE_INVALID'
          message: [
            'NIKITA_FS_ASSERT_FILETYPE_INVALID: filetype is invalid,'
            'expect "Directory" type, got "File" type,'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '

  describe 'config `filter`', ->

    they 'filter single pattern', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "match filter me"
        @fs.assert
          filter: /filter /
          target: "#{tmpdir}/a_file"
          content: /^.*match me.*$/m

    they 'filter array of patterns', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "match filter1 filter2 me"
        @fs.assert
          filter: [
            /filter1 /
            /filter2 /
          ]
          target: "#{tmpdir}/a_file"
          content: /^.*match me.*$/m

    they 'filter multi line content', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: """
          match me
          filter this string
          filter and this string
          and me
          """
        @fs.assert
          filter: /^filter.*$\n/mg
          target: "#{tmpdir}/a_file"
          content: "match me\nand me"

  describe 'config `content` string', ->
  
    they 'content match', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: "are u here"
  
    they 'content dont match', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: "not so sure"
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_CONTENT_UNEQUAL'
          message: [
            'NIKITA_FS_ASSERT_CONTENT_UNEQUAL:'
            'content does not equal the expected value,'
            'expect "are u here" to equal "not so sure",'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '
  
    they 'content match with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: "are u here"
          not: true
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_CONTENT_EQUAL'
          message: [
            'NIKITA_FS_ASSERT_CONTENT_EQUAL:'
            'content is matching,'
            'not expecting to equal "are u here",'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '
  
  describe 'config `content` regexp', ->

    they 'content match regexp', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "match me"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^.*match.*$/m

    they 'content unmatch', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^ko$/m
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_CONTENT_UNMATCH'
          message: [
            'NIKITA_FS_ASSERT_CONTENT_UNMATCH:'
            'content does not match the provided regexp,'
            'expect "are u here"'
            "to match /^ko$/m,"
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '
          
    they 'content unmatch with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "dont match me"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^ko$/m
          not: true
  
    they 'content match with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "dont match me"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^.*match.*$/m
          not: true
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_CONTENT_MATCH'
          message: [
            'NIKITA_FS_ASSERT_CONTENT_MATCH:'
            'content is matching the provided regexp,'
            'got "dont match me" to match /^.*match.*$/m,'
            "location is \"#{tmpdir}/a_file\"."
          ].join ' '
  
    they 'send custom error message', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_file"
          content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^ko$/m
          error: 'Got it'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_CONTENT_UNMATCH'
          message: 'Got it'
  
  describe 'config `md5`', ->
  
    they 'detect if file does not exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: 'XXXX'
        .should.be.rejectedWith
          code: 'NIKITA_FS_STAT_TARGET_ENOENT'
  
    they 'hash match', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: "f0a1e0f2412f62cc97178fd6b44dc978"
  
    they 'hash dont match', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: "XXXX"
        # err.message.should.eql "Invalid md5 signature: expect \"invalidmd5signature\" and got \"f0a1e0f2412f62cc97178fd6b44dc978\""
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_HASH_UNMATCH'
          message: [
            'NIKITA_FS_ASSERT_HASH_UNMATCH:'
            'an invalid md5 signature was computed,'
            'expect "XXXX", got "f0a1e0f2412f62cc97178fd6b44dc978".'
          ].join ' '
  
    they 'hash dont match with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: 'toto'
          not: true
          
    they 'hash match with not not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: "are u here"
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: "f0a1e0f2412f62cc97178fd6b44dc978"
          not: true
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_HASH_MATCH'
          message: [
            'NIKITA_FS_ASSERT_HASH_MATCH:'
            'the md5 signatures are matching,'
            'not expecting to equal "f0a1e0f2412f62cc97178fd6b44dc978".'
          ].join ' '
  
    they 'send custom error message', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: ''
        @fs.assert
          target: "#{tmpdir}/a_file"
          md5: 'toto'
          error: 'Got it'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_HASH_UNMATCH'
          message: 'Got it'
  
  describe 'config `sha1`', ->
  
    they 'validate hash', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: 'are u here'
        @fs.assert
          target: "#{tmpdir}/a_file"
          sha1: "94d1f318f02816c590bd65595c28df1dd7ff326b"
  
  describe 'config `sha256`', ->
  
    they 'validate hash', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: 'are u here'
        @fs.assert
          target: "#{tmpdir}/a_file"
          sha256: "c98fbf6b29ab2b709b642997930f3679eedd1f5f33078bc527f770c088f0463c"
  
  describe 'config `mode`', ->
  
    they 'file does not exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o755
        .should.be.rejectedWith
          code: 'NIKITA_FS_STAT_TARGET_ENOENT'
  
    they 'file matching', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '',mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0755
  
    they 'file not matching', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '',mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0644
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_MODE_UNMATCH'
          message: [
            'NIKITA_FS_ASSERT_MODE_UNMATCH:'
            'content permission don\'t match the provided mode,'
            'expect 0644, got 0755.'
          ].join ' '
  
    they 'directory match with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.mkdir
          target: "#{tmpdir}/a_file"
          content: "are u here"
          mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0755
          not: true
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_MODE_MATCH'
          message: [
            'NIKITA_FS_ASSERT_MODE_MATCH:'
            'the content permission match the provided mode,'
            'not expecting to equal 0755.'
          ].join ' '
  
    they 'directory not matching with not', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.mkdir
          target: "#{tmpdir}/a_file"
          content: "are u here"
          mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0644
          not: true
  
    they 'send custom error message', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '', mode: 0o0755
        @fs.assert
          target: "#{tmpdir}/a_file"
          mode: 0o0644
          error: 'Got it'
        .should.be.rejectedWith
          code: 'NIKITA_FS_ASSERT_MODE_UNMATCH'
          message: 'Got it'
  
  describe 'config `uid` & `gid`', ->
        
    they 'detect root ownerships', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {stdout} = await @execute 'id -u && id -g'
        [uid, gid] = stdout.split '\n'
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '', uid: uid, gid: gid
        await @fs.base.chown "#{tmpdir}/a_file", gid: gid
        @fs.assert
          target: "#{tmpdir}/a_file",
          uid: uid
          gid: gid
  
  describe 'config `trim`', ->
  
    they 'on target against content string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '\nok\n'
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: 'ok'
          trim: true
          
    they 'on target against content buffer', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '\nok\n'
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: Buffer.from 'ok'
          trim: true
  
    they 'on target against content regexp', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: '\nok\n'
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: /^ok$/
          trim: true
  
    they 'with content string', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: 'ok'
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: '\nok\n'
          trim: true
  
    they 'with content buffer', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile "#{tmpdir}/a_file", content: 'ok'
        @fs.assert
          target: "#{tmpdir}/a_file"
          content: Buffer.from '\nok\n'
          trim: true
