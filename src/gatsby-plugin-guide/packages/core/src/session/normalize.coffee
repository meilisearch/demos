
module.exports = normalize = (action) ->
  if Array.isArray action
    return action.map (action) -> normalize action
  action

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'config'
  'parent'
  'plugins'
  'registry'
  'run'
  'scheduler'
  'state'
]
