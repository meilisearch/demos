
iptables = require '../../src/utils/iptables'
{tags} = require '../test'

return unless tags.tools_iptables

describe 'utils.iptables', ->

  describe 'normalize', ->

    it 'normalize with shortcut for protocol', ->
      iptables.normalize([ # Nothing to do
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '-p': 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--protocol': 'tcp', 'tcp|--dport': '22', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'normalize with full name for protocol', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, protocol: 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--protocol': 'tcp', 'tcp|--dport': '22', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'normalize with full name for in-interface', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--in-interface': 'lo', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'normalize with full option for protocol', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 22, '--protocol': 'tcp' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--protocol': 'tcp', 'tcp|--dport': '22', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'normalize with full name without its module prefix (see state and comment)', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'udp', state: 'NEW', comment: 'krb5kdc daemon' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--protocol': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'normalize with full option without its module prefix (comment)', ->
      iptables.normalize([
        { chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'tcp', '--comment': 'My comment' }
      ]).should.eql [
        { chain: 'INPUT', '--jump': 'ACCEPT', '--protocol': 'tcp', 'tcp|--dport': '88', 'comment|--comment': '"My comment"', 'after': {'-A': 'INPUT', '--jump': 'ACCEPT', 'chain': 'INPUT'} }
      ]
    it 'preserve input', ->
      rules = [{ chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network' }]
      JSON.stringify(iptables.normalize rules).should.eql JSON.stringify(iptables.normalize rules)
    it 'preserve command', ->
      iptables.normalize([
        { chain: 'INPUT', command: '-A', jump: 'LOGGING' }
      ]).should.eql [
        { chain: 'INPUT', command: '-A', '--jump': 'LOGGING' }
      ]

    it 'discard default log-level value', ->
      iptables.normalize([
        { chain: 'LOGGING', command: '-A', '--limit': '2/min', jump: 'LOG', 'log-level': 4 }
      ]).should.eql [
        {chain: 'LOGGING', command: '-A', 'limit|--limit': '2/min', '--jump': 'LOG' }
      ]

  describe 'parse', ->

    it 'parse', ->
      iptables.parse("""
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT
      -A INPUT -p udp -m udp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """).should.eql [
        { '-P': 'INPUT ACCEPT', command: '-P', chain: 'INPUT', target: 'ACCEPT' }
        { '-P': 'FORWARD ACCEPT', command: '-P', chain: 'FORWARD', target: 'ACCEPT' }
        { '-P': 'OUTPUT ACCEPT', command: '-P', chain: 'OUTPUT', target: 'ACCEPT' }
        { rulenum: 1, '-A': 'INPUT', command: '-A', chain: 'INPUT', 'state|--state': 'RELATED,ESTABLISHED', '--jump': 'ACCEPT' }
        { rulenum: 2, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--protocol': 'icmp', '--jump': 'ACCEPT' }
        { rulenum: 3, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--in-interface': 'lo', '--jump': 'ACCEPT' }
        { rulenum: 4, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--protocol': 'tcp', 'tcp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"', '--jump': 'ACCEPT' }
        { rulenum: 5, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--protocol': 'udp', 'udp|--dport': '88', 'state|--state': 'NEW', 'comment|--comment': '"krb5kdc daemon"', '--jump': 'ACCEPT' }
        { rulenum: 6, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--protocol': 'tcp', 'state|--state': 'NEW', 'tcp|--dport': '22', '--jump': 'ACCEPT' }
        { rulenum: 7, '-A': 'INPUT', command: '-A', chain: 'INPUT', '--jump': 'REJECT', '--reject-with': 'icmp-host-prohibited' }
        { rulenum: 1, '-A': 'FORWARD', command: '-A', chain: 'FORWARD', '--jump': 'REJECT', '--reject-with': 'icmp-host-prohibited' }
      ]

    it 'parse empty lines', ->
      iptables.parse('\n-P INPUT ACCEPT\n').should.eql [ { '-P': 'INPUT ACCEPT', command: '-P', chain: 'INPUT', target: 'ACCEPT' } ]

    it 'parse new chain (N)', ->
      iptables.parse("""
      -N LOGGING
      """).should.eql [
        { '-N': 'LOGGING', command: '-N', chain: 'LOGGING' }
      ]

    it 'parse logs', -> #  --log-tcp-sequence --log-tcp-options --log-ip-options --log-uid
      iptables.parse("""
      -A LOGGING -j LOG --log-level 5 --log-prefix "IPTables-Dropped: "
      """).should.eql [
        { rulenum: 1, '-A': 'LOGGING', command: '-A', chain: 'LOGGING', '--jump': 'LOG', '--log-level': '5', '--log-prefix': '"IPTables-Dropped: "' }
      ]

  describe 'command', ->

    it 'see change in protocol', ->
      iptables.command([
        { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '--in-interface': 'eth1', '--protocol': 'tcp', 'tcp|--dport': '88', '-j': 'ACCEPT' }
      ], [
        { chain: 'INPUT', '-j': 'ACCEPT', '--in-interface': 'eth0', '--protocol': 'tcp', 'tcp|--dport': '88' }
      ]).should.eql [
        "iptables -I INPUT 1 -j ACCEPT --in-interface eth0 --protocol tcp -m tcp --dport 88"
      ]

    it 'see change in comment', ->
      iptables.command([
        { rulenum: 5, '-A': 'INPUT', chain: 'INPUT', '--in-interface': 'eth1', 'comment|--comment': '"kadmin daemon"', '-j': 'ACCEPT' }
      ], [
        { chain: 'INPUT', '-j': 'ACCEPT', '--in-interface': 'eth1', 'comment|--comment': '"krb5kdc daemon"' }
      ]).should.eql [
        "iptables -R INPUT 5 --in-interface eth1 -m comment --comment \"krb5kdc daemon\" -j ACCEPT"
      ]

    it 'respect chain', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -N LOGGING
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j LOGGING
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 7
      -A LOGGING -j DROP
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'LOGGING', command: '-A', '--limit': '2/min', jump: 'LOG', 'log-prefix': 'IPTables-Dropped: ', 'log-level': 5 }
      ]).should.eql [
        'iptables -R LOGGING 1 -m limit --limit 2/min --jump LOG --log-prefix "IPTables-Dropped: " --log-level 5'
      ]

    it 'parse and detect a change', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT
      -A INPUT -p udp -m udp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        # Removing state
        chain: 'INPUT', jump: 'ACCEPT', dport: 88, '-p': 'tcp', '--comment': 'krb5kdc daemon'
      ]).should.eql [ 'iptables -R INPUT 4 --protocol tcp -m tcp --dport 88 -m state --state NEW -m comment --comment "krb5kdc daemon" --jump ACCEPT' ]

    it 'compare minus sign (IPTable silently remove minus sign)', ->
      oldrules = iptables.parse """
      -A INPUT -p tcp -m tcp --dport 389 -m state --state NEW -m comment --comment "LDAP (non-secured)" -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 636 -m state --state NEW -m comment --comment "LDAP (secured)" -j ACCEPT
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', dport: 389, protocol: 'tcp', state: 'NEW', comment: "LDAP (non-secured)" }
        { chain: 'INPUT', jump: 'ACCEPT', dport: 636, protocol: 'tcp', state: 'NEW', comment: "LDAP (secured)" }
      ]).should.eql []

    it 'compare comment without any special char', ->
      oldrules = iptables.parse """
      -A INPUT -p udp -m udp --dport 53 -m state --state NEW -m comment --comment "Named" -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 53 -m state --state NEW -m comment --comment "Named" -j ACCEPT
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', dport: 53, protocol: 'tcp', state: 'NEW', comment: "Named" }
        { chain: 'INPUT', jump: 'ACCEPT', dport: 53, protocol: 'udp', state: 'NEW', comment: "Named" }
      ]).should.eql []

    it 'create new chain (N)', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', command: '-A', jump: 'LOGGING' }
        { chain: 'LOGGING', command: '-A', '--limit': '2/min', jump: 'LOG', 'log-prefix': 'IPTables-Dropped: ', 'log-level': 5 }
        { chain: 'LOGGING', command: '-A', jump: 'DROP' }
      ]).should.eql [
        'iptables -N LOGGING'
        'iptables -A INPUT --jump LOGGING'
        'iptables -A LOGGING --jump LOG --log-prefix "IPTables-Dropped: " --log-level 5 -m limit --limit 2/min'
        'iptables -A LOGGING --jump DROP'
      ]

    it 'discard existing rune in new chain (N)', ->
      oldrules = iptables.parse """
      -N LOGGING
      -A INPUT -j LOGGING
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      -A LOGGING -m limit --limit 2/min -j LOG --log-level 5 --log-prefix "IPTables-Dropped: "
      -A LOGGING -j DROP
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', command: '-A', jump: 'LOGGING' }
        { chain: 'LOGGING', command: '-A', '--limit': '2/min', jump: 'LOG', 'log-prefix': 'IPTables-Dropped: ', 'log-level': 5 }
        { chain: 'LOGGING', command: '-A', jump: 'DROP' }
      ]).should.eql []

  describe 'position', ->

    it 'default after "-i lo -j ACCEPT"', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network' }
      ]).should.eql ['iptables -I INPUT 5 --jump ACCEPT --source 10.10.10.0/24 -m comment --comment "Local Network"']

    it 'after insert new rule', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', after: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql ['iptables -I INPUT 4 --jump ACCEPT --source 10.10.10.0/24 -m comment --comment "Local Network"']

    it 'after shouldnt move when already after', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -s 10.10.10.0/24 -m comment --comment "Local Network" -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', after: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql []

    it 'after insert and modify', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        # Removing state
        {chain: 'INPUT', jump: 'ACCEPT', dport: '22', '-p': 'tcp', '--comment': 'SSH'}
        {chain: 'INPUT', jump: 'ACCEPT', dport: '88', '-p': 'tcp', '--comment': 'krb5kdc daemon'}
      ]).should.eql [
        'iptables -R INPUT 4 --protocol tcp -m tcp --dport 22 --jump ACCEPT -m comment --comment "SSH"'
        'iptables -I INPUT 5 --jump ACCEPT --protocol tcp -m tcp --dport 88 -m comment --comment "krb5kdc daemon"'
      ]

    it 'before insert new rule', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', before: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql ['iptables -I INPUT 3 --jump ACCEPT --source 10.10.10.0/24 -m comment --comment "Local Network"']

    it 'before shouldnt move when already before', ->
      oldrules = iptables.parse """
      -P INPUT ACCEPT
      -P FORWARD ACCEPT
      -P OUTPUT ACCEPT
      -A INPUT -s 10.10.10.0/24 -m comment --comment "Local Network" -j ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -j REJECT --reject-with icmp-host-prohibited
      -A FORWARD -j REJECT --reject-with icmp-host-prohibited
      """
      iptables.command(oldrules, iptables.normalize [
        { chain: 'INPUT', jump: 'ACCEPT', source: "10.10.10.0/24", comment: 'Local Network', before: {'in-interface': 'lo', jump: 'ACCEPT' } }
      ]).should.eql []
