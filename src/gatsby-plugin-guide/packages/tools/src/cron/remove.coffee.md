
# `nikita.tools.cron.remove`

Remove job(s) on crontab.

## Example

```js
const {$status} = await nikita.cron.remove({
  command: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *',
  user: 'service'
})
console.info(`Cron entry was removed: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'command':
            type: 'string'
            description: '''
            The shell command of the job. By default all jobs will match.
            '''
          'user':
            type: 'string'
            description: '''
            The user of the crontab. The SSH user by default.
            '''
          'when':
            type: 'string'
            description: '''
            Cron-styled time string. Defines the frequency of the cron job. By
            default all frequency will match.
            '''
        required: ['command']

## Handler

    handler = ({config, tools: {log}}) ->
      if config.user?
        log message: "Using user #{config.user}", level: 'INFO'
        crontab = "crontab -u #{config.user}"
      else
        log message: "Using default user", level: 'INFO'
        crontab = "crontab"
      status = false
      jobs = []
      {stdout, stderr} = await @execute
        $shy: true
        command: "#{crontab} -l"
      throw Error 'User crontab not found' if /^no crontab for/.test stderr
      myjob = if config.when then utils.regexp.escape config.when else '.*'
      myjob += utils.regexp.escape " #{config.command}"
      regex = new RegExp myjob
      jobs = stdout.trim().split '\n'
      for job, i in jobs
        continue unless regex.test job
        log message: "Job '#{job}' matches. Removing from list", level: 'WARN'
        status = true
        jobs.splice i, 1
      log message: "No Job matches. Skipping", level: 'INFO'
      return unless status
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

    utils = require '../utils'
