
# `nikita.krb5.ktutil.add`

Create and manage a keytab for an existing principal. It's different than ktadd
in the way it can manage several principal on one keytab.

## Example

```js
const {$status} = await nikita.krb5.ktutil.add({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  password: 'password'
})
console.info(`Keytab was created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin':
            $ref: 'module://@nikitajs/krb5/src/execute#/definitions/config/properties/admin'
          'enctypes':
            type: 'array', items: type: 'string'
            default: ['aes256-cts-hmac-sha1-96', 'aes128-cts-hmac-sha1-96', 'des3-cbc-sha1','arcfour-hmac']
            description: '''
            The enctypes used by krb5_server.
            '''
          'gid':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/gid'
          'keytab':
            type: 'string'
            description: '''
            Path to the file storing key entries.
            '''
          'mode':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/mode'
          'password':
            type: 'string'
            description: '''
            Password associated to this principal; required if no randkey is
            provided.
            '''
          'principal':
            type: 'string'
            description: '''
            Principal to be created.
            '''
          'realm':
            type: 'string'
            description: '''
            The realm the principal belongs to.
            '''
          'uid':
            $ref: 'module://@nikitajs/file/lib/index#/definitions/config/properties/uid'
        required: ['keytab', 'password', 'principal']

## Handler

    handler = ({config, tools: {log}}) ->
      if /^\S+@\S+$/.test config.principal
        config.realm ?= config.principal.split('@')[1]
      else
        throw Error 'Property "realm" is required in principal' unless config.realm
        config.principal = "#{config.principal}@#{config.realm}"
      entries = []
      princ_entries = []
      princ = {}
      command = null
      # Get keytab entries
      {$status, stdout, code} = await @execute
        $shy: true
        command: "echo -e 'rkt #{config.keytab}\nlist -e -t \n' | ktutil"
        code_skipped: 1
      if $status
        log message: "Principal exist in Keytab, check kvno validity", level: 'DEBUG'
        for line in utils.string.lines stdout
          continue unless match = /^\s*(\d+)\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*\(([\w|-]*)\)\s*$/.exec line
          [_, slot, kvno, timestamp, principal, enctype] = match
          kvno = parseInt kvno, 10
          entries.push
            slot: slot
            kvno: kvno
            timestamps: timestamp
            principal: principal.trim()
            enctype: enctype
        princ_entries = entries.filter((e) -> "#{e.principal}" is "#{config.principal}").reverse()
      # Get principal information and compare to keytab entries kvnos
      {$status, stdout} = await @krb5.execute
        $shy: true
        admin: config.admin
        command: "getprinc -terse #{config.principal}"
      if $status
        values = utils.string.lines(stdout)[1]
        # Check if a ticket exists for this
        throw Error "Principal does not exist: '#{config.principal}'" unless values
        values = values.split '\t'
        mdate = parseInt(values[2], 10) * 1000
        kvno = parseInt values[8], 10
        princ = mdate: mdate, kvno: kvno
      # read keytab and check kvno validities
      command = null
      tmp_keytab = "#{config.keytab}.tmp_nikita_#{Date.now()}"
      for enctype in config.enctypes
        entry = if princ_entries.filter( (entry) -> entry.enctype is enctype).length is 1 then entries.filter( (entry) -> entry.enctype is enctype)[0] else null
        #entries.filter( (entry) -> entry.enctype is enctype).length is 1
        # add_entry_command = "add_entry -password -p #{config.principal} -k #{princ.kvno} -e #{enctype}\n#{config.password}\n"
        if entry? and (entry?.kvno isnt princ.kvno)
          command ?= "echo -e 'rkt #{config.keytab}\n"
          # remove entry if kvno not identical
          log message: "Remove from Keytab kvno '#{entry.kvno}', principal kvno '#{princ.kvno}'", level: 'INFO'
          command += "delete_entry #{entry?.slot}\n"
      if entries.length > princ_entries.length
        if command?
          await @execute
            command: command + "wkt #{tmp_keytab}\nquit\n' | ktutil"
        if command?
          await @fs.move
            source: tmp_keytab
            target: config.keytab
      if (entries.length is princ_entries.length) and command?
        await @fs.remove
          target: config.keytab
      # write entries in keytab
      command = null
      for enctype in config.enctypes
        entry = if princ_entries.filter( (entry) -> entry.enctype is enctype).length is 1 then entries.filter( (entry) -> entry.enctype is enctype)[0] else null
        if (entry?.kvno isnt princ.kvno) or !entry?
          command ?= "echo -e '"
          command += "add_entry -password -p #{config.principal} -k #{princ.kvno} -e #{enctype}\n#{config.password}\n"
      if command?
        await @execute
          command: command + "wkt #{config.keytab}\n' | ktutil"
      # Keytab ownership and permissions
      if config.uid? or config.gid?
        await @fs.chown
          target: config.keytab
          uid: config.uid
          gid: config.gid
      return unless config.mode
      await @fs.chmod
        target: config.keytab
        mode: config.mode

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'krb5'
        definitions: definitions

## Fields in 'getprinc -terse' output

princ-canonical-name
princ-exp-time
last-pw-change
pw-exp-time
princ-max-life
modifying-princ-canonical-name
princ-mod-date
princ-attributes <=== This is the field you want
princ-kvno
princ-mkvno
princ-policy (or 'None')
princ-max-renewable-life
princ-last-success
princ-last-failed
princ-fail-auth-count
princ-n-key-data
ver
kvno
data-type[0]
data-type[1]

## Dependencies

    utils = require '@nikitajs/core/lib/utils'
    {mutate} = require 'mixme'
