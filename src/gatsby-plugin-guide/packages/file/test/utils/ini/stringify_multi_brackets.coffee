
{ini} = require '../../../src/utils'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.stringify_multi_brackets', ->

  it 'stringify test eol', ->
    res = ini.stringify_multi_brackets
      user: preference: color: true
      group:
        name: 'us'
    , eol: '|'
    res.should.eql '[user]|  [[preference]]|    color = true|[group]|  name = us|'

  it 'stringify style', ->
    ini.stringify_multi_brackets
      '###########################################################################': null
      '# Some comments': null
      group1:
        key1a: '"value1a"'
        '# comment': null
        key1b: '1'
        '# Administrators': null
        '# ----------------': null
        group1a1:
          '## [[[admin1aX]]]': null
          key1a1: 'value1a1'
        group1b:
          '# comment': 'value'
          '## double comment': 'value'
          key1b1: 'value1b1'
      group2:
        key1: 'value1b'
    .should.eql """
    ###########################################################################
    # Some comments
    [group1]
      key1a = "value1a"
      # comment
      key1b = 1
      # Administrators
      # ----------------
      [[group1a1]]
        ## [[[admin1aX]]]
        key1a1 = value1a1
      [[group1b]]
        # comment = value
        ## double comment = value
        key1b1 = value1b1
    [group2]
      key1 = value1b

    """

  it 'stringify simple values before complex values', ->
    ini.stringify_multi_brackets
      group1:
        key1: 'value1'
        group1b:
          key1b1: 'value1b1'
        key2: 'value2'
      group2:
        key1: 'value1b'
    .should.eql """
      [group1]
        key1 = value1
        key2 = value2
        [[group1b]]
          key1b1 = value1b1
      [group2]
        key1 = value1b

      """

  it 'validate array values', ->
    (->
      ini.stringify_multi_brackets
        user:
          preference:
            language: [true, 'ok']
    ).should.throw 'Stringify Invalid Value: expect a string for key language, got true'

  it 'convert array to multiple keys', ->
    ini.stringify_multi_brackets
      'user':
        'preference':
          'language': ['c', 'c++', 'ada']
    .should.eql """
    [user]
      [[preference]]
        language = c
        language = c++
        language = ada
    
    """
