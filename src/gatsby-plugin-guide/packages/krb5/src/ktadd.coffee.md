
# `nikita.krb5.ktadd`

Create and manage a keytab. This function is usually not used directly but instead
called by the `krb5.addprinc` function.

## Example

```js
const {$status} = await nikita.krb5.ktadd({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
})
console.info(`keytab was created or updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin':
            $ref: 'module://@nikitajs/krb5/src/execute#/definitions/config/properties/admin'
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
          'keytab':
            type: 'string'
            description: '''
            Path to the file storing key entries.
            '''
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
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
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
        required: ['keytab', 'principal']

## Handler

    handler = ({config, tools: {log}}) ->
      if /^\S+@\S+$/.test config.admin.principal
        config.realm ?= config.admin.principal.split('@')[1]
      else
        throw Error 'Property "realm" is required unless present in principal' unless config.realm
        config.principal = "#{config.principal}@#{config.realm}"
      keytab = {} # keytab[principal] ?= {kvno: null, mdate: null}
      princ = {} # {kvno: null, mdate: null}
      # Get keytab information
      {$status, stdout} = await @execute
        $shy: true
        command: "export TZ=GMT; klist -kt #{config.keytab}"
        code_skipped: 1
      if $status
        log message: "Keytab exists, check kvno validity", level: 'DEBUG'
        for line in utils.string.lines stdout
          continue unless match = /^\s*(\d+)\s+([\d\/:]+\s+[\d\/:]+)\s+(.*)\s*$/.exec line
          [_, kvno, mdate, principal] = match
          kvno = parseInt kvno, 10
          mdate = Date.parse "#{mdate} GMT"
          # keytab[principal] ?= {kvno: null, mdate: null}
          if not keytab[principal] or keytab[principal].kvno < kvno
            keytab[principal] = kvno: kvno, mdate: mdate
      # Get principal information
      if keytab[config.principal]?
        {$status, stdout} = await @krb5.execute
          $shy: true
          admin: config.admin
          command: "getprinc -terse #{config.principal}"
        if $status
          # return do_ktadd() unless -1 is stdout.indexOf 'does not exist'
          values = utils.string.lines(stdout)[1]
          # Check if a ticket exists for this
          throw Error "Principal does not exist: '#{config.principal}'" unless values
          values = values.split '\t'
          mdate = parseInt(values[2], 10) * 1000
          kvno = parseInt values[8], 10
          princ = mdate: mdate, kvno: kvno
          log message: "Keytab kvno '#{keytab[config.principal]?.kvno}', principal kvno '#{princ.kvno}'", level: 'INFO'
          log message: "Keytab mdate '#{new Date keytab[config.principal]?.mdate}', principal mdate '#{new Date princ.mdate}'", level: 'INFO'
      # Remove principal from keytab
      if keytab[config.principal]? and (keytab[config.principal]?.kvno isnt princ.kvno or keytab[config.principal].mdate isnt princ.mdate)
        await @krb5.execute
          admin: config.admin
          command: "ktremove -k #{config.keytab} #{config.principal}"
      # Create keytab and add principal
      if not keytab[config.principal]? or (keytab[config.principal]?.kvno isnt princ.kvno or keytab[config.principal].mdate isnt princ.mdate)
        await @fs.mkdir
          target: "#{path.dirname config.keytab}"
      if not keytab[config.principal]? or (keytab[config.principal]?.kvno isnt princ.kvno or keytab[config.principal].mdate isnt princ.mdate)
        await @krb5.execute
          admin: config.admin
          command: "ktadd -k #{config.keytab} #{config.principal}"
      # Keytab ownership and permissions
      if config.uid? or config.gid?
        await @fs.chown
          target: config.keytab
          uid: config.uid
          gid: config.gid
      if config.mode?
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

    path = require 'path'
    utils = require '@nikitajs/core/lib/utils'
    {mutate} = require 'mixme'
