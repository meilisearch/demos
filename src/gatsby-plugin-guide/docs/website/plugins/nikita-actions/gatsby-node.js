const crypto = require('crypto')
const nikita = require('nikita')
const path = require('path')
const fs = require('fs').promises
const constants = require('fs').constants

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions
  createTypes(`
    """
    NikitaAction Node
    """
    type NikitaAction implements Node @dontInfer {
      name: String!
      action: [String]!
      version: NikitaActionVersion!
      slug: String!
      edit_url: String!
      packageName: String!
      srcPath: String
    }
    type NikitaActionVersion {
      name: String!
      alias: String!
    }
  `)
}

exports.sourceNodes = async (
  { actions: { createNode }, createNodeId },
  { include }
) => {
  const nikitaActions = await nikita.registry.get({ flatten: true })
  nikitaActions.forEach(async (action) => {
    // Filter actions without modules
    if (!action.metadata || !action.metadata.module) return
    // Get custom fields
    const name = action.action.join('.')
    const packageName = action.metadata.module.split('/')[1]
    const currentVersion = '1',
      version = '1' // Currently only 1 version
    var versionAlias = currentVersion == version ? 'current' : `v${version}`
    const actionPath =
      action.action[0] === packageName
        ? action.action.join('/')
        : `${packageName}/${action.action.join('/')}` // for core actions
    const slug = `/${versionAlias}/actions/${actionPath}/`
    // Find the source markdown file
    var srcPath = action.metadata.module
      .replace('@nikitajs/', '')
      .replace(/\/lib$/, '/src')
      .replace('/lib/', '/src/')
    include = path.resolve(include)
    srcPath = path.join(path.basename(include), srcPath)
    try {
      await fs.access(
        path.resolve(include, '../', `${srcPath}.coffee.md`),
        constants.R_OK
      ) // check if exists
      srcPath = `${srcPath}.coffee.md`
    } catch (err) {
      await fs.access(
        path.resolve(include, '../', `${srcPath}/index.coffee.md`),
        constants.R_OK
      ) // check if exists
      srcPath = `${srcPath}/index.coffee.md`
    }
    const edit_url = `https://github.com/adaltas/node-nikita/edit/master/${srcPath}`
    // Create node
    createNode({
      // Custom fields
      name: name,
      action: action.action,
      version: {
        name: version,
        alias: versionAlias,
      },
      packageName: packageName,
      metadata: action.metadata,
      srcPath: srcPath, // needed to filter Mdx
      slug: slug,
      edit_url: edit_url,
      // Gatsby fields
      id: createNodeId(slug),
      parent: null,
      children: [],
      internal: {
        type: 'NikitaAction',
        // // An optional field. This is rarely used. It is used when a source plugin sources data it doesn’t know how to transform
        // content: content,
        // the digest for the content of this node. Helps Gatsby avoid doing extra work on data that hasn’t changed.
        contentDigest: crypto.createHash(`md5`).update(slug).digest(`hex`),
      },
    })
  })
}

exports.createResolvers = ({ createResolvers, createNodeId }) => {
  createResolvers({
    NikitaAction: {
      package: {
        type: 'NikitaPackage',
        resolve(source, args, context, info) {
          // We use an author's `email` as foreign key in `BlogJson.authors`
          return context.nodeModel
            .getAllNodes(
              { type: 'NikitaPackage' },
              { connectionType: 'NikitaPackage' }
            )
            .filter(
              (target) =>
                source.packageName == target.name &&
                source.version.name == target.version.name
            )[0]
        },
      },
      parent: {
        resolve(source, args, context, info) {
          // We use an author's `email` as foreign key in `BlogJson.authors`
          return context.nodeModel
            .getAllNodes({ type: 'Mdx' }, { connectionType: 'Mdx' })
            .filter((target) =>
              new RegExp(source.srcPath).test(target.fileAbsolutePath)
            )[0]
        },
      },
    },
  })
}

exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/action.js`)
  return graphql(`
    {
      actions: allNikitaAction {
        nodes {
          slug
        }
      }
    }
  `).then((result) => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.actions.nodes.forEach((node) => {
      createPage({
        path: node.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
    })
  })
}
