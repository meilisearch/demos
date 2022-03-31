
{ini} = require '../../../src/utils'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.stringify', ->

  it 'honors option separator', ->
    ini.stringify
      user: preference: color: 'rouge'
    , separator: ':'
    .should.eql """
    [user.preference]
    color:rouge

    """

  it 'handle boolean', ->
    ini.stringify
      user: preference:
        a_string: 'a value'
        a_boolean_true: true
        a_boolean_false: false
    .should.eql """
    [user.preference]
    a_string = a value
    a_boolean_true

    """
