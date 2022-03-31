
{ini} = require '../../../src/utils'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.stringify_brackets_then_curly', ->

  it 'option eol', ->
    ini.stringify_brackets_then_curly
      user: preference: color: true
      group:
        name: 'us'
    ,
      eol: '|'
    .should.eql '[user]| preference = {|  color = true| }||[group]| name = us||'

  it 'stringify simple values before array values', ->
    ini.stringify_brackets_then_curly
      group1:
        key1: 'value1'
        group1b:
          key1b1: 'value1b1'
          key1b2: ['value1b2a', 'value1b2b']
        key2: 'value2'
      group2:
        key1: 'value1b'
    .should.eql """
      [group1]
       key1 = value1
       group1b = {
        key1b1 = value1b1
        key1b2 = value1b2a
        key1b2 = value1b2b
       }
       key2 = value2

      [group2]
       key1 = value1b


      """
