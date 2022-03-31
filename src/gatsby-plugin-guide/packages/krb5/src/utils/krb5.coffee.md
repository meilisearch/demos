
# Miscellaneous kerberos functions

    module.exports = krb5 =
      kinit: (config) ->
        command = "kinit"
        if config.keytab is true then " -k"
        else if config.keytab and typeof config.keytab is 'string' then command += " -kt #{config.keytab}"
        else if config.password then command = "echo #{config.password} | #{command}"
        else throw Error "Incoherent config: expects one of keytab or password"
        command += " #{config.principal}"
        command = krb5.su config, command
      su: (config, command) ->
        command = "su - #{config.uid} -c '#{command}'" if config.uid
        command
