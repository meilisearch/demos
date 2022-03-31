
# Nikita "ipa" package

The "ipa" package provides Nikita actions for various FreeIPA operations.

## Running the test

The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```
# For windows and osx user
../lxd/bin/cluster start
export NIKITA_HOME=/nikita
# Start the server
coffee ./env/ipa/start.coffee
# Run all the tests
lxc exec freeipa --cwd /nikita/packages/ipa npm test
# Run selected tests
lxc exec freeipa --cwd /nikita/packages/ipa npx mocha test/user/exists.coffee
# Enter the IPA container
lxc exec freeipa --cwd /nikita/packages/ipa bash
npm test
```

## Notes

### Permission denied on tmp

[FreeIPA install issue](https://bugzilla.redhat.com/show_bug.cgi?id=1678793)

```
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: '/tmp/tmp_Tm1l_'
```

Host must have `fs.protected_regular` set to `0`, eg `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, no restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.
