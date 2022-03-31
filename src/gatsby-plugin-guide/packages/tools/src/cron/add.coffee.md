
# `nikita.tools.cron.add`

Register a job on crontab.

## Example

```js
const {$status} = await nikita.cron.add({
  command: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *',
  user: 'service'
})
console.info(`Cron entry created or modified: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'command':
            type: 'string'
            minLength: 1
            description: '''
            The shell command of the job.
            '''
          'exec':
            type: 'boolean'
            description: '''
            If true, then command will be executed just after if added to crontab.
            '''
          'match':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            The cron entry to match, a string will be converted to a regexp and an
            undefined or null value will match the exact command.
            '''
          'user':
            type: 'string'
            description: '''
            The user of the crontab. The SSH user by default.
            '''
          'when':
            type: 'string'
            pattern: '^(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\\d+(ns|us|µs|ms|s|m|h))+)|((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})$'
            # noBooleanCoercion: true
            # noNumberCoercion: true
            description: '''
            Cron-styled time string. Defines the frequency of the cron job.
            '''
        required: ['command', 'when']

## Handler

    handler = ({config, tools: {log}}) ->
      if config.user?
        log message: "Using user #{config.user}", level: 'DEBUG'
        crontab = "crontab -u #{config.user}"
      else
        log message: "Using default user", level: 'DEBUG'
        crontab = "crontab"
      jobs = []
      {stdout} = await @execute
        command: "#{crontab} -l"
        code: [0, 1]
      new_job = "#{config.when} #{config.command}"
      # remove useless last element
      regex =
        unless config.match then new RegExp ".* #{utils.regexp.escape config.command}"
        else if typeof config.match is 'string' then new RegExp config.match
        else if util.isRegExp config.match then config.match
        else throw Error "Invalid option 'match'"
      added = true
      jobs = for job, i in utils.string.lines stdout.trim()
        if regex.test job
          added = false
          break if job is new_job # Found job, stop here
          log message: "Entry has changed", level: 'WARN'
          utils.diff job, new_job, config
          job = new_job
          modified = true
        continue unless job
        job
      if added
        jobs.push new_job
        log message: "Job not found in crontab, adding", level: 'WARN'
      jobs = null unless added or modified
      return $status: false unless jobs
      if config.exec
        await @execute
          command: if config.user? then "su -l #{config.user} -c '#{config.command}'" else config.command
      await @execute
        command: """
        #{crontab} - <<EOF
        #{if jobs then jobs.join '\n', '\nEOF' else 'EOF'}
        """

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    util = require 'util'
    utils = require '../utils'
