
const crypto = require("crypto")
const path = require("path")
const fs = require('fs').promises
const constants = require('fs').constants

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions
  createTypes(`
    """
    NikitaPackage Node
    """
    type NikitaPackage implements Node @infer {
      name: String!
      fullName: String!
      version: NikitaPackageVersion!
      slug: String!
      edit_url: String!
      description: String
      keywords: [String]
    }
    type NikitaPackageVersion {
      name: String!
      alias: String!
      fullName: String!
    }
  `)
}

exports.onCreateNode = async (
  { actions: {createNode}, createNodeId, node },
  { include, ignore }
) => {
  if (!include) return
  if (node.internal.type !== `Mdx`) return
  // Filter non-readme files
  const regexp = new RegExp(`${path.resolve(include)}/.*/README.md$`)
  if (!regexp.test(node.fileAbsolutePath)) return 
  // Filter ignored packages
  if (ignore && ignore.length > 0) {
    const regexpIgnore = new RegExp(ignore.map(item => path.resolve(include, item)).join('|'))
    if (regexpIgnore.test(node.fileAbsolutePath)) return
  }
  // Get package.json
  const packageJsonPath = path.join(node.fileAbsolutePath, '../package.json')
  await fs.access(packageJsonPath, constants.R_OK)  // check if exists
  const packageJson = require(packageJsonPath)
  // Get custom fields
  const name = packageJson.name.replace('@nikitajs/', '')
  const currentVersion = '1', version = '1' // Currently only 1 version
  var versionAlias = currentVersion == version ? 'current' : `v${version}`
  const slug = `/${versionAlias}/packages/${name}/`
  const edit_url = `https://github.com/adaltas/node-nikita/edit/master/${path.relative(path.join(include, '../'), node.fileAbsolutePath)}`
  // Inherit fields
  createNode({
    // Custom fields
    name: name,
    fullName: packageJson.name,
    version: {
      name: version,
      alias: versionAlias,
      fullName: packageJson.version
    },
    description: packageJson.description,
    keywords: packageJson.keywords,
    slug: slug,
    edit_url: edit_url,
    // Gatsby fields
    id: createNodeId(slug),
    parent: node.id,
    children: [],
    internal: {
      type: 'NikitaPackage',
      // // An optional field. This is rarely used. It is used when a source plugin sources data it doesn’t know how to transform 
      // content: content,
      // the digest for the content of this node. Helps Gatsby avoid doing extra work on data that hasn’t changed.
      contentDigest: crypto
        .createHash(`md5`)
        .update(JSON.stringify(node))
        .digest(`hex`)
    }
  })
}

exports.createResolvers = ({ createResolvers, createNodeId }) => {
  createResolvers({
    NikitaPackage: {
      actions: {
        type: ['NikitaAction'],
        resolve(source, args, context, info) {
          // We use an author's `email` as foreign key in `BlogJson.authors`
          return context.nodeModel
          .getAllNodes(
            { type: 'NikitaAction' },
            { connectionType: 'NikitaAction' }
          )
          .filter( target =>
            source.name == target.packageName && source.version.name == target.version.name
          )
        }
      }
    }
  })
}

exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/package.js`)
  return graphql(`
    {
      packages: allNikitaPackage {
        nodes {
          slug
        }
      }
    }
  `).then(result => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.packages.nodes.forEach( node => {
      createPage({
        path: node.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
    })
  })
}
