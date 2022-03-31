
crypto = require 'crypto'

module.exports =
  sanitize: (versions, fill='x') ->
    is_array = Array.isArray versions
    versions = [versions] unless is_array
    for version, i in versions
      version = version.split('.')
      version = version.slice 0, 3
      version.push fill for _ in [0...3-version.length]
      version = version.map (v) ->
        # Ubuntu style, remove trailing '0'
        return "#{parseInt v, 10}" unless isNaN parseInt v, 10
        # Arch style, strip /-\d$/
        v = v.split('-')[0] if /\d+-\d+/.test v
        v
      versions[i] = version.join('.')
    if is_array then versions else versions[0]
  satisfies: require('semver').satisfies
