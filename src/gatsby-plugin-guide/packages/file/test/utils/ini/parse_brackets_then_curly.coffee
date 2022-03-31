
{ini} = require '../../../src/utils'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.parse_brackets_then_curly', ->

  it 'parse braket, no values', ->
    ini.parse_brackets_then_curly """
    [key1]
    [key2]
    """
    .should.eql
      key1: {}
      key2: {}

  it 'parse braket then curly', ->
    ini.parse_brackets_then_curly """
    [key1]
      key11 = {
      }
      key12 = {
        key121 = value 121
        key122 = value 122
      }
    [key2]
    [key3]
      key31 = {
      }
    """
    .should.eql
      key1:
        key11: {}
        key12:
          key121: 'value 121'
          key122: 'value 122'
      key2: {}
      key3:
        key31: {}

  it 'parse braket then multi curly', ->
    ini.parse_brackets_then_curly """
    [key1]
      key11 = {
        key111 = {
          key1111 = {
          }
          key1112 = {
          }
        }
      }
      key12 = {
        key121 = {
          key1211 = {
            key12111 = value 12111
          }
        }
        key122 = value 122
      }
    [key2]
      key21 = {
        key211 = value 211
      }
    """
    .should.eql
      key1:
        key11:
          key111:
            key1111: {}
            key1112: {}
        key12:
          key121:
            key1211:
              key12111: 'value 12111'
          key122: 'value 122'
      key2:
        key21:
          key211: 'value 211'
