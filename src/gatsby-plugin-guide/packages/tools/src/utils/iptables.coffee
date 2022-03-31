
utils = require '@nikitajs/core/lib/utils'
jsesc = require 'jsesc'
{merge} = require 'mixme'


equals = (obj1, obj2, keys) ->
  keys1 = Object.keys obj1
  keys2 = Object.keys obj2
  if keys
    keys1 = keys1.filter (k) -> keys.indexOf(k) isnt -1
    keys2 = keys2.filter (k) -> keys.indexOf(k) isnt -1
  else keys = keys1
  return false if keys1.length isnt keys2.length
  for k in keys
    return false if obj1[k] isnt obj2[k]
  return true

module.exports = iptables =
  # add_properties: ['target', 'protocol', 'dport', 'in-interface', 'out-interface', 'source', 'target']
  add_properties: [
    '--protocol', '--source', '---target', '--jump', '--goto'
    '--in-interface', '--out-interface', '--fragment'
    'tcp|--source-port', 'tcp|--sport', 'tcp|--target-port', 'tcp|--dport', 'tcp|--tcp-flags', 'tcp|--syn', 'tcp|--tcp-option'
    'udp|--source-port', 'udp|--sport', 'udp|--target-port', 'udp|--dport'
  ]
  # modify_properties: ['state', 'comment']
  modify_properties: [
    '--set-counters',
    '--log-level', '--log-prefix', '--log-tcp-sequence', '--log-tcp-options', # LOG
    '--log-ip-options', '--log-uid', # LOG
    'state|--state', 'comment|--comment'
    'limit|--limit']
  commands_arguments: # Used to compute rulenum
    '-A': ['chain']
    '-D': ['chain']
    '-I': ['chain']
    '-R': ['chain']
    '-N': ['chain']
    '-X': ['chain']
    '-P': ['chain', 'target']
    '-L': true, '-S': true, '-F': true, '-Z': true, '-E': true
  commands_inverted:
    '--append': '-A'
    '--delete': '-D'
    '--insert': '-I'
    '--replace': '-R'
    '--new-chain': '-N'
    '--delete-chain': '-X'
    '--policy': '-P'
    '--list': '-L'
    '--list-rules': '-S'
    '--flush': '-F'
    '--zero': '-Z'
    '--rename-chain': '-E'
  # parameters: ['-p', '-s', '-d', '-j', '-g', '-i', '-o', '-f', '-c'] # , '--log-prefix'
  # parameters_inverted:
  #   '--protocol': '-p', '--source': '-s', '--target': '-d', '--jump': '-j'
  #   '--goto': '-g', '--in-interface': '-i', '--out-interface': '-o',
  #   '--fragment': '-f', '--set-counters': '-c'
  parameters: ['--protocol', '--source', '--target', '--jump', '--goto',
    '--in-interface', '--out-interface', '--fragment', '--set-counters',
    '--log-level', '--log-prefix', '--log-tcp-sequence', '--log-tcp-options', # LOG
    '--log-ip-options', '--log-uid' # LOG
  ]
  parameters_inverted:
    '-p': '--protocol', '-s': '--source', '-d': '--target', '-j': '--jump'
    '-g': '--goto', '-i': '--in-interface', '-o': '--out-interface',
    '-f': '--fragment', '-c': '--set-counters'
  protocols:
    tcp: ['--source-port', '--sport', '--target-port', '--dport', '--tcp-flags', '--syn', '--tcp-option']
    udp: ['--source-port', '--sport', '--target-port', '--dport']
    udplite: []
    icmp: []
    esp: []
    ah: []
    sctp: []
    all: []
  modules:
    state: ['--state']
    comment: ['--comment']
    limit: ['--limit']
  command_args: (command, rule) ->
    for k, v of rule
      continue if ['chain', 'rulenum', 'command'].indexOf(k) isnt -1
      continue unless v?
      if match = /^([\w]+)\|([-\w]+)$/.exec k
        module = match[1]
        arg = match[2]
        command += " -m #{module}"
        command += " #{arg} #{v}"
      else
        command += " #{k} #{v}"
    command
  command_replace: (rule) ->
    rule.rulenum ?= 1
    iptables.command_args "iptables -R #{rule.chain} #{rule.rulenum}", rule
  command_insert: (rule) ->
    rule.rulenum ?= 1
    iptables.command_args "iptables -I #{rule.chain} #{rule.rulenum}", rule
  command_append: (rule) ->
    rule.rulenum ?= 1
    iptables.command_args "iptables -A #{rule.chain}", rule
  command: (oldrules, newrules) ->
    commands = []
    new_chains = []
    old_chains = oldrules
    .map (oldrule) -> oldrule.chain
    .filter (chain, i, chains) -> ['INPUT', 'FORWARD', 'OUTPUT'].indexOf(chain) < 0 and chains.indexOf(chain) >= i
    # Create new chains
    for newrule in newrules
      if ['INPUT', 'FORWARD', 'OUTPUT'].indexOf(newrule.chain) < 0 and new_chains.indexOf(newrule.chain) < 0 and old_chains.indexOf(newrule.chain) < 0
        new_chains.push newrule.chain
        commands.push "iptables -N #{newrule.chain}"
    for newrule in newrules
      # break if newrule.rulenum? #or newrule.command is '-A'
      if newrule.after and not newrule.rulenum
        rulenum = 0
        for oldrule, i in oldrules
          continue unless oldrule.command is '-A' and oldrule.chain is newrule.chain
          rulenum++
          if equals newrule.after, oldrule, Object.keys newrule.after
            # newrule.rulenum = rulenum + 1
            newrule.rulenum = oldrule.rulenum + 1
            # break
        delete newrule.after
      if newrule.before and not newrule.rulenum
        rulenum = 0
        for oldrule, i in oldrules
          continue unless oldrule.command is '-A' and oldrule.chain is newrule.chain
          rulenum++
          if equals newrule.before, oldrule, Object.keys newrule.before
            # newrule.rulenum = rulenum
            newrule.rulenum = oldrule.rulenum
            break
        delete newrule.before
      create = true
      # Get add properties present in new rule
      add_properties = utils.array.intersect iptables.add_properties, Object.keys newrule
      for oldrule in oldrules
        continue if oldrule.chain isnt newrule.chain
        # Add properties are the same
        if equals newrule, oldrule, add_properties
          create = false
          # Check if we need to update
          if not equals newrule, oldrule, iptables.modify_properties
            # Remove the command
            baserule = merge oldrule
            for k, v of baserule
              baserule[k] = undefined if iptables.commands_arguments[k]
              baserule.command = undefined
              newrule.rulenum = undefined
            commands.push iptables.command_replace merge baserule, newrule
        # Add properties are different
      if create
        commands.push if newrule.command is '-A' then iptables.command_append newrule else iptables.command_insert newrule
    commands
  normalize: (rules, position = true) ->
    oldrules = if Array.isArray rules then rules else [rules]
    newrules = []
    for rule in oldrules
      rule = merge rule
      newrule = {}
      # Search for commands and parameters
      for k, v of rule
        nk = null
        # Normalize value as string
        v = rule[k] = "#{v}" if typeof v is 'number'
        # Normalize key as shortname (eg "-k")
        if k is 'chain' or k is 'rulenum' or k is 'command'
          # Final name, mark key as done
          nk = k
        else if k[0..1] is '--' and iptables.parameters.indexOf(k) >= 0
          # nk = iptables.parameters_inverted[k]
          nk = k
        else if k[0] isnt '-' and iptables.parameters.indexOf("--#{k}") >= 0
          # nk = iptables.parameters_inverted["--#{k}"]
          nk = "--#{k}"
        # else if iptables.parameters.indexOf(k) isnt -1
        else if iptables.parameters_inverted[k]
          nk = iptables.parameters_inverted[k]
          # nk = k
        # Key has changed, replace it
        if nk
          newrule[nk] = v
          rule[k] = null
      # Add prototol specific options
      if protocol = newrule['--protocol']
        for k in iptables.protocols[protocol]
          if rule[k]
            newrule["#{protocol}|#{k}"] = rule[k]
            rule[k] = null
          else if rule[k[2..]]
            newrule["#{protocol}|#{k}"] = rule[k[2..]]
            rule[k[2..]] = null
      for k, v of rule
        continue unless v
        if k is 'after' or k is 'before'
          newrule[k] = iptables.normalize v, false
          continue
        k = "--#{k}" unless k[0..1] is '--'
        for mk, mvs of iptables.modules
          for mv in mvs
            if k is mv
              newrule["#{mk}|#{k}"] = v
              rule[k] = null
      for k, v of newrule
        continue if k is 'command'
        # Discard default log level value
        if k is '--log-level' and v is '4'
          delete newrule[k]
          continue
        # IPTables silently remove minus signs
        # v = v.replace '-', '' if /\-/.test v
        v = v.replace '-', '' if k is 'comment|--comment'
        v = jsesc v, quotes: 'double', wrap: true if ['--log-prefix', 'comment|--comment'].indexOf(k) isnt -1
        newrule[k] = v
      newrules.push newrule
    if position and newrule.command isnt '-A' then for newrule in newrules
      # newrule.before = '-A': 'INPUT', chain: 'INPUT', '--jump': 'REJECT', '--reject-with': 'icmp-host-prohibited' unless newrule.after? or newrule.before?
      newrule.after = '-A': 'INPUT', chain: 'INPUT', '--jump': 'ACCEPT' unless newrule.after? or newrule.before?
    if Array.isArray rules then newrules else newrules[0]

  ###
  Parse the result of `iptables -S`
  ###
  parse: (stdout) ->
    rules = []
    command_index = {}
    for line in utils.string.lines stdout
      continue if line.length is 0
      rule = {}
      i = 0
      key = ''
      value = ''
      module = null
      while i <= line.length
        char = line[i]
        forceflush = i is line.length
        newarg = (i is 0 and char is '-') or line[(i-1)..i] is ' -'
        if newarg or forceflush
          if value
            value = value.trim()
            if key is '-m'
              module = value
            else
              key = "#{module}|#{key}" if module
              key = iptables.parameters_inverted[key] if iptables.parameters_inverted[key]
              rule[key] = value
            # First key is a command
            if iptables.commands_arguments[key]
              # Determine rule number
              if Array.isArray iptables.commands_arguments[key]
                rule.command = key
                for v, j in value.split ' '
                  rule[iptables.commands_arguments[key][j]] = v
                command_index[rule.chain] ?= 0
                rule.rulenum = ++command_index[rule.chain] if ['-P', '-N'].indexOf(key) is -1
            key = ''
            value = ''
            break if forceflush
          key += char
          while (char = line[++i]) isnt ' ' # and line[i]?
            key += char
          # if iptables.parameters.indexOf(key) isnt -1
          if iptables.parameters_inverted[key]
            module = null
          continue
        if char is '"'
          while (char = line[++i]) isnt '"'
            value += char
          i++
          continue
        while char+(char = line[++i]) isnt ' -' and i < line.length
          # IPTable silently remove minus sign from comment
          continue if char is '-' and key is '--comment'
          value += char
      rules.push rule
    rules
