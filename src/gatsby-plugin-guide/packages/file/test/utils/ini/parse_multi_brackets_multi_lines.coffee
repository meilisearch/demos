
{ini} = require '../../../src/utils'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.parse_multi_brackets_multi_lines', ->

  it 'parse', ->
    ini.parse_multi_brackets_multi_lines """
      ###########################################################################
      # Some comments

      [group1]

        key1a="value1a"

        # comment
        key1b=1

        # Administrators
        # ----------------
        [[group1a1]]
          ## [[[admin1aX]]]
          key1a1 = value1a1
        [[group1b]]
          # comment
          ## double comment
          key1b1 = value1b1
          following value
      [group2]
        key1=value1b
        """
    ,
      comment : '#'
    .should.eql
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
          '# comment': null
          '## double comment': null
          key1b1: "value1b1following value"
      group2:
        key1: 'value1b'
