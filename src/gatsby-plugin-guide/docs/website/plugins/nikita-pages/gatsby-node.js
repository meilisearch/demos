
const crypto = require("crypto")
const path = require("path")
const { createFilePath } = require('gatsby-source-filesystem')

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions
  createTypes(`
    """
    NikitaPage Node
    """
    type NikitaPage implements Node @infer {
      frontmatter: NikitaPageFrontmatter
      version: NikitaPageVersion!
      slug: String!
      edit_url: String
    }
    type NikitaPageFrontmatter {
      disabled: Boolean
      title: String
      navtitle: String
      sort: Int
    }
    type NikitaPageVersion {
      name: String
      alias: String
    }
  `)
}

exports.onCreateNode = (
  { actions: {createNode}, createNodeId, node, getNode },
  { include, doNotVersion }
) => {
  if (!include) return
  if (node.internal.type !== `Mdx`) return
  // Filter non-docs pages
  const regexp = new RegExp(path.resolve(include))
  if (!regexp.test(node.fileAbsolutePath)) return 
  // Custom fields
  node.frontmatter.disabled = !!node.frontmatter.disabled
  var slug = createFilePath({ node, getNode })
  var currentVersion = '1', version = '1' // Currently only 1 version
  var versionAlias = currentVersion == version ? 'current' : `v${version}`
  // Do not version
  if (doNotVersion && doNotVersion.length > 0) {
    const regexpDoNotVersion = new RegExp(
      doNotVersion
      .map(item => path.resolve(include, item))
      .join('|')
    )
    if(regexpDoNotVersion.test(node.fileAbsolutePath)) {
      var version = null
      var versionAlias = null
    }
  }
  slug = versionAlias ? `/${versionAlias}${slug}` : slug
  const edit_url =
    "https://github.com/adaltas/node-nikita/edit/master/" +
    path.relative(`${__dirname}/../../../../`, node.fileAbsolutePath)
  const copy = {}
  const filter = ['children', 'id', 'internal', 'fields', 'parent', 'type']
  Object.keys(node).map( key => {
    if(!filter.some(k => k === key)) copy[key] = node[key]
  })
  createNode({
    // Custom fields
    ...copy,
    version: {
      name: version,
      alias: versionAlias
    },
    versionAlias: versionAlias,
    slug: slug,
    edit_url: edit_url,
    // Gatsby fields
    id: createNodeId(slug),
    parent: node.id,
    children: [],
    internal: {
      type: 'NikitaPage',
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

exports.createPages = ({ actions, graphql }) => {
  const { createPage, createRedirect } = actions
  const template = path.resolve(`src/templates/page.js`)
  return graphql(`
    {
      pages: allNikitaPage {
        nodes {
          frontmatter {
            disabled
          }
          slug
        }
      }
    }
  `).then(result => {
    if (result.errors) {
      return Promise.reject(result.errors)
    }
    result.data.pages.nodes.forEach( node => {
      if (node.frontmatter.disabled) return
      createPage({
        path: node.slug,
        component: template,
        context: {}, // additional data can be passed via context
      })
    })
  })
}
