// React
import React from 'react'
// Material UI
import { withStyles } from '@material-ui/core/styles'
// Gatsby
import { graphql } from 'gatsby'
// MDX
import { MDXProvider } from "@mdx-js/react"
import { MDXRenderer } from "gatsby-plugin-mdx"
// Local
import Layout from '../components/Layout'

const styles = theme => ({})

const Template = ({
  data
}) => {
  const { page } = data // data.markdownRemark holds our post data
  return (
    <Layout page={{
        ...page.frontmatter,
        slug: page.slug,
        edit_url: page.edit_url,
        version: page.version.alias,
        tableOfContents: page.parent.tableOfContents
      }}>
      <MDXProvider>
        <MDXRenderer>{page.parent.body}</MDXRenderer>
      </MDXProvider>
    </Layout>
  )
}
export default withStyles(styles, { withTheme: true })(Template)

export const pageQuery = graphql`
  query($path: String!) {
    page: nikitaPage(slug: { eq: $path }) {
      slug
      edit_url
      version {
        alias
      }
      frontmatter {
        title
        titleHtml
        description
        keywords
      }
      parent {
        ... on Mdx {
          body
          tableOfContents(maxDepth: 2)
        }
      }
    }
  }
`
