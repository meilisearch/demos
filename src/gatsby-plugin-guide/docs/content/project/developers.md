---
navtitle: Developer
sort: 5
---

# Developer information

You are encouraged to [contribute](/project/contribute/) to Nikita. There are multiple ways to offer assistance to the project. To fix and write actions, you will have to get your hands dirty and dive into the source code. This page describes how to setup your developer and testing environment and how tests are organized and executed.

Before starting with Nikita development, read the [project architecture](/project/architecture/), it presents how to project is organized in the Git repository.

## Tests execution

Nikita targets Unix-like systems including Linux and macOS. Windows is not supported as a targeting node where actions are executed. It is however known to work as a Nikita host. This means you can run Nikita from a Windows host and target Linux nodes over SSH.

Nikita use [Mocha](https://mochajs.org/) and [Should.js](https://shouldjs.github.io/). All tests are all located inside the `test` folders.

### Running all tests

The command `yarn test` run both on the local machine as well as on containerized and virtualized environments to simulate various operating systems and execution contexts. Lerna can run multiple commands in parallel with the `--concurrency` option:

```
npx lerna run test --stream --concurrency 8
```

### Running local tests

For the local tests to execute successfully, you must:

* be able to ssh yourself (eg `ssh $(whoami)@localhost`) without a password
* be online (attempt to fetch an FTP file)

Local tests are executed with the command `yarn test:local`. It can be executed globally from the project root directoy or selectively inside each package. Inside a package, to speed test execution, you can pass the `--parallel` Mocha argument, for example:

```bash
cd packages/core
yarn run test:local --parallel
```

To execute a subset of the tests, go to the package folder and pass a globing expression to Mocha such as `cd ./packages/{package} && npx mocha 'test/**/*.coffee'`.

For example, to only test the `nikita.file.ini` actions, run the following:

```bash
cd packages/file && npx mocha test/ini.coffee
# Or
yarn workspace @nikitajs/file exec mocha test/ini.coffee 
# Or
npx lerna --scope @nikitajs/file exec mocha test/ini.coffee
```

### Running environment tests

For the environment tests to execute successfully, you must:

* Install and configure a [Docker client](https://www.docker.com/).
* Install and configure an [LXD client](https://linuxcontainers.org/lxd/introduction/).

Environment tests are executed with the command `yarn test:env`. To execute a single environment, go to the targeted `env` folder such as `./packages/{package}/env/{env}` and execute its `run.sh` script.

## Configuration customization

Tests load a configuration file. Its purpose is to parameterize the Nikita sessions and to filter the execution of tests with a tagging system.

By default, the configuration files are located in each package folder. They are named `test.coffee`. A sample file is provided as well named `test.coffee.sample`. If a configuration file does not exists, the sample file is copied.

You can also customize the path to the configuration module by setting the `NIKITA_TEST_MODULE` environmental variable.

## SSH or locally

Why even choose? When it makes sense, the majority of tests run twice. Once without an SSH connection and once with an SSH connection pointing to `localhost` by default. To achieve this behavior, we extended [Mocha](https://mochajs.org/) by providing an alternative to the `it` function in the name of `they`. You can find it in the [mocha-they package](https://github.com/adaltas/node-ssh2-they).

For example, this test will only be executed locally:

```js
const nikita = require('nikita');

describe('Simple Test', () => {
  it('Check a file is touched', () => {
    nikita
    .file.touch('/tmp/a_file')
    .fs.assert('/tmp/a_file')
  })
})
```

While the same test using `they` will be executed locally and remotely using provided configuration:

```js
const nikita = require('nikita');
const {config} = require('./test');
const they = require('mocha-they')(config);

describe('Simple Test', () => {
  they('Check a file is touched', (ssh) => {
    nikita({$ssh: ssh})
    .file.touch('/tmp/a_file')
    .fs.assert('/tmp/a_file');
  })
})
```

## Environments

Some tests depend on particular settings to run successfully. Some actions are specific to a particular Linux distribution or issue internally alternatives commands which must be validated. Other actions depend on a service that is not always available on the host machine such as a database connection.

The environment tests require the presence of [Docker](https://www.docker.com/) and [LXD](https://linuxcontainers.org/lxd/introduction/) clients.

Based on your environment support, targeted tests can be activated from the configuration. Tests are labeled with tags. The environment defines the test coverage by activating tags in their `test.coffee` configuration file. For example, to activate the MariaDB tests located in the ["db" package](https://github.com/adaltas/node-nikita/blob/master/packages/db/env/mariadb/test.coffee), set the `tags.db` property to `true` and configure the `db.mariadb` properties accordingly.

## Docker

To ensure tests are executed in a proper environment, we leverage [Docker](https://docs.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). To each environment corresponds a directory inside the "./env" folder. Inside each folder, you will find the "docker-compose.yml" declaration file and its associated resources.

- `docker-compose.yml`   
  The [Docker Compose](https://docs.docker.com/compose/) file declares the Nikita container with its test environment as well as its service dependencies such as databases services.
- `Dockerfile`   
  The [Dockerfile](https://docs.docker.com/engine/reference/builder/) declares instructions to build the containers.
- `test.coffee`   
  The configuration file is used to activate selected tests and configured the Nikita sessions executed inside.

The commands to execute the tests are common to every Docker environment and provide a lot of flexibility. From any environment directory, you can run:

* `docker compose up --abort-on-container-exit`   
  Run the all test suite from the host shell.
* `docker compose run --rm nodejs`   
  Enter inside the Nikita container and execute your commands.
* `docker compose run --rm nodejs 'test/**/*.coffee'`   
  Run a subset of the tests from the host shell.

Here's an example to run tests on CentOS 7:

```bash
# Download the source code
git clone https://github.com/adaltas/node-nikita.git nikita
cd nikita
# Install dependencies
yarn install
# Navigate to the target environment
cd packages/core/env/centos7
# Run all tests
docker compose up --abort-on-container-exit
# Run a subset of the tests
docker compose run --rm nodejs test/actions/execute/*.coffee
# Enter bash console
docker compose run --rm nodejs
```

## LXD

Some tests are executed using [LXD](https://linuxcontainers.org/lxd/introduction/). The tests require a local LXD client. To install it on a Linux host, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non-Linux hosts, you can set up the client to communicate with a remote LXD server hosted on a virtual machine. However, you will have to mount the project directory into the "/nikita" folder of the virtual machine. The provided [Vagrantfile](https://github.com/adaltas/node-nikita/blob/master/packages/lxd/assets/Vagrantfile) definition inside the "packages/lxd/assets" folder will set you up.

For Windows and macOS users, the procedure is abstracted inside the `./bin/cluster start` command:

```bash
# For Windows and macOS users
cd packages/lxd
./bin/cluster start
yarn test
```

The manual commands to make it work are below:

* Install:

```bash
# Initialize the VM
cd packages/lxd/assets && vagrant up && cd ../../
# Set up LXD client
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
# Navigate to the target environment
cd ipa/env/ipa
# Initialize the container
npx coffee start.coffee
```

* Update the VM:

```bash
lxc remote switch local
lxc remote remove nikita
# Note, password is "secret"
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
```

If you are running into an issue with permission on the "tmp" folder as below:

```bash
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: '/tmp/tmp_Tm1l_'
```

Host must have `fs.protected_regular` set to `0`r, eg `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, no restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.

Here's a complete example to run tests for the ["ipa" package](https://github.com/adaltas/node-nikita/tree/master/packages/ipa):

```bash
# For Windows and macOS users
./packages/lxd/bin/cluster start
export NIKITA_HOME=/nikita
cd packages/ipa
# Start the server
npx coffee ./env/ipa/start.coffee
# Run all the tests
lxc exec nikita-ipa --cwd /nikita/packages/ipa npx mocha 'test/**/*.coffee'
# Run selected tests
lxc exec nikita-ipa --cwd /nikita/packages/ipa npx mocha 'test/user/exists.coffee'
# Enter the IPA container
lxc exec nikita-ipa --cwd /nikita/packages/ipa bash
```
