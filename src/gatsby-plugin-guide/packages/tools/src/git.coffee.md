
# `nikita.tools.git`

Create and synchronize a git repository.

## Output

* `$status`   
  Value "true" if repository was created or modified.

## Example

The following action make sure the git repository is synchronized to the latest
HEAD revision.

```js
const {$status} = await nikita.tools.git({
  source: 'https://github.com/adaltas/node-nikita.git'
  target: '/tmp/nikita'
})
console.info(`Repo was synchronized: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'revision':
            type: 'string'
            default: 'HEAD'
            description: '''
            Git revision, branch or tag.
            '''
          'source':
            type: 'string'
            description: '''
            Git source repository address.
            '''
          'target':
            type: 'string'
            description: '''
            Directory where to clone the repository.
            '''
        required: ['source', 'target']

## Handler

    handler = ({config, ssh, tools: {path}}) ->
      # Start real work
      repo_uptodate = false
      {exists: repo_exists} = await @fs.base.exists target: config.target
      if repo_exists
        # return callback Error "Destination not a directory, got #{config.target}" unless stat.isDirectory()
        gitDir = "#{config.target}/.git"
        {exists: is_git} = await @fs.base.exists target: gitDir
        throw Error "Not a git repository" unless is_git
      else
        await @execute
          command: "git clone #{config.source} #{config.target}"
          cwd: path.dirname config.target
      if repo_exists
        {$status: repo_uptodate} = await @execute
          $shy: true
          command: """
          current=`git log --pretty=format:'%H' -n 1`
          target=`git rev-list --max-count=1 #{config.revision}`
          echo "current revision: $current"
          echo "expected revision: $target"
          if [ $current != $target ]; then exit 3; fi
          """
          # stdout: process.stdout
          cwd: config.target
          trap: true
          code_skipped: 3
      unless repo_uptodate
        await @execute
          command: "git checkout #{config.revision}"
          cwd: config.target

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
