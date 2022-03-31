
path = require 'path'
{Minimatch} = require 'minimatch'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.fs.glob', ->
  return unless tags.posix
  
  they 'argument is converted to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call ->
        @fs.glob "#{tmpdir}", ({config}) ->
          config.target
        .should.be.fulfilledWith "#{tmpdir}"

  they 'should traverse a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/*"
      files.sort().should.eql [
        path.normalize "#{tmpdir}/test/a_dir"
        path.normalize "#{tmpdir}/test/a_file"
      ]

  they 'should traverse a directory recursively', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.mkdir "#{tmpdir}/test/a_dir/a_sub_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/a_sub_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**"
      files.sort().should.eql [
        "#{tmpdir}/test"
        "#{tmpdir}/test/a_dir"
        "#{tmpdir}/test/a_dir/a_sub_dir"
        "#{tmpdir}/test/a_dir/a_sub_dir/a_file"
        "#{tmpdir}/test/a_file"
      ]
      # Default behavior
      (new Minimatch('/a_dir/**').match '/a_dir/').should.be.true()

  they 'should match an extension patern', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/a_file.coffee", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file.coffee", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/*.coffee"
      files.sort().should.eql [
        path.normalize "#{tmpdir}/test/a_file.coffee"
      ]

  they 'should match an extension patern in recursion', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/a_file.coffee", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file.coffee", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**/*.coffee"
      files.sort().should.eql [
        path.normalize "#{tmpdir}/test/a_dir/a_file.coffee"
        path.normalize "#{tmpdir}/test/a_file.coffee"
      ]
  
  they 'return an empty array on no match', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {files} = await @fs.glob "#{tmpdir}/invalid/*.coffee"
      files.sort().should.eql []
  
  they 'config `dot`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/.git", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/.gitignore", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**", dot: true
      files.sort().should.eql [
        "#{tmpdir}/test"
        "#{tmpdir}/test/.git"
        "#{tmpdir}/test/a_dir"
        "#{tmpdir}/test/a_dir/.gitignore"
      ]
  
  they 'config `trailing`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.mkdir "#{tmpdir}/test"
      await @fs.base.writeFile "#{tmpdir}/test/a_file", content: ''
      await @fs.base.mkdir "#{tmpdir}/test/a_dir"
      await @fs.base.writeFile "#{tmpdir}/test/a_dir/a_file", content: ''
      {files} = await @fs.glob "#{tmpdir}/test/**", trailing: true
      files.sort().should.eql [
        "#{tmpdir}/test/"
        "#{tmpdir}/test/a_dir/"
        "#{tmpdir}/test/a_dir/a_file"
        "#{tmpdir}/test/a_file"
      ]
