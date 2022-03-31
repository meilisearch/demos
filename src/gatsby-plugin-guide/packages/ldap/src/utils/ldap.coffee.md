
# Utils LDAP

    module.exports =
      acl:

## Parse ACLs

Parse one or multiple "olcAccess" entries.

Example:

```
ldap.acl
.parse [ '{0}to attrs=userPassword,userPKCS12 by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read by self write by anonymous auth by * none' ]
.should.eql [
  index: 0
  to: 'attrs=userPassword,userPKCS12'
  by: [ 'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
    'dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read'
    'self write'
    'anonymous auth'
    '* none'
  ]
]
```

        parse: (olcAccesses) ->
          isArray = Array.isArray olcAccesses
          olcAccesses = [olcAccesses] unless isArray
          olcAccesses = for olcAccess, i in olcAccesses
            match = /^\{(\d+)\}to\s+(.*?)(\s*by\s+|$)(.*)$/.exec olcAccess
            throw Error 'Invalid olcAccess entry' unless match
            index: parseInt match[1], 10
            to: match[2]
            by: match[4].split /\s+by\s+/
          if isArray then olcAccesses else olcAccesses[0]

# Stringify ACLs

Stringify one or multiple "olcAccess" entries.

        stringify: (olcAccesses) ->
          isArray = Array.isArray olcAccesses
          olcAccesses = [olcAccesses] unless isArray
          for olcAccess, i in olcAccesses
            value = "{#{olcAccess.index}}to #{olcAccess.to}"
            for bie in olcAccess.by
              value += " by #{bie}"
            olcAccesses[i] = value
          if isArray then olcAccesses else olcAccesses[0]

      index:

## Parse Index

Parse one or multiple "olcDbIndex" entries.

        parse: (indexes) ->
          isArray = Array.isArray indexes
          indexes = [indexes] unless isArray
          indexes.forEach (index, i) ->
            indexes = {} if i is 0
            [k,v] = index.split ' '
            indexes[k] = v
          if isArray then indexes else indexes[0]

## Stringify Index

Stringify one or multiple "olcDbIndex" entries.

        stringify: (indexes) ->
          isArray = Array.isArray indexes
          indexes = [indexes] unless isArray
          indexes = for k, v of indexes
            "#{k} #{v}"
          if isArray then indexes else indexes[0]
