
# `nikita.docker.load`

Load Docker images.

## Output

* `err`   
  Error object if any.
* `$status`   
  True if container was loaded.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

```js
const {$status} = await nikita.docker.load({
  image: 'nikita/load_test:latest',
  machine: machine,
  source: source + "/nikita_load.tar"
})
console.info(`Image was loaded: ${$status}`);
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'checksum':
            type: 'string'
            description: '''
            If provided, will check if attached input archive to checksum already
            exist, not native to docker but implemented to get better performance.
            '''
          'docker':
            $ref: 'module://@nikitajs/docker/src/tools/execute#/definitions/docker'
          'input':
            type: 'string'
            description: '''
            TAR archive file to read from.
            '''
          'source':
            type: 'string'
            description: '''
            Alias for the "input" option.
            '''

## Handler

    handler = ({config, tools: {log}}) ->
      # Validate parameters
      config.input ?= config.source
      throw Error 'Missing input parameter' unless config.input?
      command = "load -i #{config.input}"
      # need to records the list of image to see if status is modified or not after load
      # for this we print the existing images as REPOSITORY:TAG:IMAGE
      # parse the result to record images as an array of   {'REPOSITORY:TAG:'= 'IMAGE'}
      images = {}
      delete config.command
      log message: 'Storing previous state of image', level: 'INFO'
      log message: 'No checksum provided', level: 'INFO' if !config.checksum?
      log message: "Checksum provided :#{config.checksum}", level: 'INFO' if config.checksum
      config.checksum ?= ''
      {stdout} = await @docker.tools.execute
        command: "images | grep -v '<none>' | awk '{ print $1\":\"$2\":\"$3 }'"
      # skip header line, wi skip it here instead of in the grep  to have
      # an array with at least one not empty line
      if utils.string.lines(stdout).length > 1
        for image in utils.string.lines stdout
          image = image.trim()
          if image != ''
            infos = image.split(':')
            # if image is here we skip
            log message: "Image already exist checksum :#{config.checksum}, repo:tag \"#{infos[0]}:#{infos[1]}\"", level: 'INFO' if infos[2] == config.checksum
            return false if infos[2] == config.checksum
            images["#{infos[0]}:#{infos[1]}"] = "#{infos[2]}"
      log message: "Start Loading #{config.input} ", level: 'INFO'
      await @docker.tools.execute
        command: command
      {stdout, stderr} = await @docker.tools.execute
        command: 'images | grep -v \'<none>\' | awk \'{ print $1":"$2":"$3 }\''
      new_images = {}
      status = false
      log message: 'Comparing new images', level: 'INFO'
      if utils.string.lines(stdout).length > 1
        for image in utils.string.lines stdout.toString()
          if image != ''
            infos = image.split(':')
            new_images["#{infos[0]}:#{infos[1]}"] = "#{infos[2]}"
      for new_k, new_image of new_images
        if !images[new_k]?
          status = true
          break
        else
          for k, image of images
            if image != new_image && new_k == k
              status = true
              log message: 'Identical images', level: 'INFO'
              break
      $status: status, stdout: stdout, stderr: stderr
          
## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'docker'
        definitions: definitions

## Dependencies

    utils = require './utils'
