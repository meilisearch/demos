
# `nikita.ldap.acl`

Create new [ACLs](acls) for the OpenLDAP server.

## Example

```js
const {$status} = await nikita.ldap.acl({
  dn: '',
  acls: [{
    place_before: 'dn.subtree="dc=domain,dc=com"',
    to: 'dn.subtree="ou=users,dc=domain,dc=com"',
    by: [
      'dn.exact="ou=users,dc=domain,dc=com" write',
      'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read',
      '* none'
    ]
  },{
    to: 'dn.subtree="dc=domain,dc=com"',
    by: [
      'dn.exact="ou=kerberos,dc=domain,dc=com" write'
    ]
  }]
})
console.info(`ACL modified: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      config.acls = [config.acls] if is_object_literal config.acls

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'acls':
            type: 'array'
            description: '''
            In case of multiple acls, regroup "place_before", "to" and "by" as an
            array.
            '''
            items:
              type: 'object'
              properties:
                'by':
                  type: 'array'
                  items: type: 'string'
                  description: '''
                  Who to grant access to and the access to grant as an array (eg:
                  `{..., by:["ssf=64 anonymous auth"]}`).
                  '''
                'first':
                  type: 'boolean'
                  description: '''
                  Please ACL in the first position.
                  '''
                'place_before':
                  type: 'string'
                  description: '''
                  Place before another rule defined by "to".
                  '''
                'to':
                  type: 'string'
                  description: '''
                  What to control access to as a string.
                  '''
          'dn':
            type: 'string'
            description: '''
            Distinguish name storing the "olcAccess" property, using the database
            address (eg: "olcDatabase={2}bdb,cn=config").
            '''
          'suffix':
            type: 'string'
            description: '''
            The suffix associated with the database (eg: "dc=example,dc=org"),
            used as an alternative to the `dn` configuration.
            '''
        required: ['acls']

## Handler

    handler = ({config, tools: {log}}) ->
      $status = false
      # Get DN
      unless config.dn
        log message: "Get DN of the database to modify", level: 'DEBUG'
        {dn} = await @ldap.tools.database config,
          suffix: config.suffix
        config.dn = dn
        log message: "Database DN is #{dn}", level: 'INFO'
      for acl in config.acls
        # Get ACLs
        log message: "List all ACL of the directory", level: 'DEBUG'
        {stdout} = await @ldap.search config,
          attributes: ['olcAccess']
          base: "#{config.dn}"
          filter: '(olcAccess=*)'
        current = null
        olcAccesses = []
        for line in utils.string.lines stdout
          if match = /^olcAccess: (.*)$/.exec line
            olcAccesses.push current if current? # Push previous rule
            current = match[1] # Create new rule
          else if current?
            if /^ /.test line # Append to existing rule
              current += line.substr 1
            else # Close the rule
              olcAccesses.push current
              current = null
        olcAccesses = utils.ldap.acl.parse olcAccesses
        # Diff
        olcAccess = null
        # Find match "to" property
        for access, i in olcAccesses
          if acl.to is access.to
            olcAccess = merge access
            olcAccess.old = access
            break
        if olcAccess # Modify rule or bypass perfect match
          is_perfect_match = true
          not_found_acl = []
          if acl.by.length isnt olcAccess.by.length
            is_perfect_match = false
          else
            for acl_by, i in acl.by
              is_perfect_match = false if acl_by isnt olcAccess.by[i]
              found = true
              for access_by in olcAccess.by
                found = false if acl_by isnt access_by
              not_found_acl.push acl_by unless found
          if is_perfect_match
            log message: "No modification to apply", level: 'INFO'
            continue
          if not_found_acl.length
            log message: "Modify access after undefined acl", level: 'INFO'
            for access_by in olcAccess.by
              not_found_acl.push access_by
            olcAccess.by = not_found_acl
          else
            log message: "Modify access after reorder", level: 'INFO'
            log? 'nikita `ldap.acl`: m'
            olcAccess.by = acl.by
        else
          log message: "Insert a new access", level: 'INFO'
          index = olcAccesses.length
          if acl.first # not tested
            index = 0
          if acl.place_before
            for access, i in olcAccesses
              index = i if access.to is acl.place_before
          else if acl.after
            for access, i in olcAccesses
              index = i+1 if access.to is config.after
          olcAccess = index: index, to: acl.to, by: acl.by, add: true
        # Save
        old = utils.ldap.acl.stringify olcAccess.old if olcAccess.old
        olcAccess = utils.ldap.acl.stringify olcAccess
        
        operations =
          dn: config.dn
          changetype: 'modify'
          attributes: []
        if old
          operations.attributes.push
            type: 'delete'
            name: 'olcAccess'
          operations.attributes.push
            type: 'add'
            name: 'olcAccess'
            value: olcAccess
        else
          operations.attributes.push
            type: 'add'
            name: 'olcAccess'
            value: olcAccess
        await @ldap.modify config,
          operations: operations
        $status = true
      $status

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'ldap'
        definitions: definitions

## Dependencies

    {is_object_literal, merge} = require 'mixme'
    utils = require './utils'

[acls]: http://www.openldap.org/doc/admin24/access-control.html
[tuto]: https://documentation.fusiondirectory.org/fr/documentation/convert_acl
