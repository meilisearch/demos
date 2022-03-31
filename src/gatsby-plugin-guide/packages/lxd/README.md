
# Nikita "lxd" package

The "lxd" package provides Nikita actions for various LXD operations.

## Running the test

The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```bash
# For windows and MacOS users
./bin/cluster start
npm test
```

## Notes

### Networks

The LXD tests create two bridge networks:

* Nikita LXD public: `nktlxdpub`, `192.0.2.1/30` (reserved IP subnet ssigned as TEST-NET-1)
* Nikita LXD private: `nktlxdprv`, `192.0.2.5/30` (reserved IP subnet ssigned as TEST-NET-1)

To avoid collision, other tests must create and use their own bridge.

### Windows and MacOS users

LXD is only available on Linux. To work around this limitation, we run LXD in a virtual machine which is managed by [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

The Nikita project folder is mounted in `/nikita` inside the VM. The LXD tests don't need to know about it because they only interact with the local `lxc` command. For the tests who need to know this path, the location of the Nikita folder inside the VM can be defined with `export NIKITA_HOME=/nikita`. For example, the FreeIPA tests in 'packages/ipa/env/ipa' use it.

The procedure is abstracted inside the `./bin/cluster start` command. Below are the manual commands to make it work if you wish to do it yourself.

Install:

```bash
# Initialize the VM
cd assets && vagrant up && cd..
# Set up LXD client
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
# Initialize the container
npx coffee start.coffee
```

Update the VM:

```bash
lxc remote switch local
lxc remote remove nikita
lxc remote add nikita --accept-certificate --password secret 127.0.0.1:8443
lxc remote switch nikita
```


### Permission denied on tmp

[FreeIPA install issue](https://bugzilla.redhat.com/show_bug.cgi?id=1678793)

```
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: '/tmp/tmp_Tm1l_'
```

Host must have `fs.protected_regular` set to `0`, eg `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, no restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.
