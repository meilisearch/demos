
# LXD runner

The LXD runner is used to execute Nikita unit test inside LXD containers. It receives a cluster configuration and provide the following commands:

* `enter`
  Enter inside the container console.
* `exec`
  Execute a command inside the container console.
* `run`
  Start and stop the container and execute all the tests.
* `start`
  Start the container.
* `stop`
  Stop the container.
* `test`
  Execute all the tests.
* `help`
  Display help information

For example, go to the `packages/ipa/env/ipa` environment folder and run `coffee index.coffee` to print the help.
