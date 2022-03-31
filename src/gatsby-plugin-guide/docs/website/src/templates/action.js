// React
import React from 'react'
// Gatsby
import { graphql } from 'gatsby'
// MDX
import { MDXProvider } from "@mdx-js/react"
import { MDXRenderer } from "gatsby-plugin-mdx"
// Local
import Layout from '../components/Layout'

const Template = ({
  data
}) => {
  const { page } = data
  return (
    <Layout page={{
        keywords: page.package.keywords,
        description: page.parent.excerpt,
        title: `Action "${page.name}"`,
        slug: page.slug,
        version: page.version.alias,
        edit_url: page.edit_url,
        tableOfContents: page.parent.tableOfContents}}>
      <MDXProvider>
        <MDXRenderer>{page.parent.body}</MDXRenderer>
      </MDXProvider>
    </Layout>
  )
}
export default Template

export const pageQuery = graphql`
  query($path: String!) {
    page: nikitaAction(slug: { eq: $path }) {
      slug
      edit_url
      package {
        id
        keywords
      }
      name
      version {
        alias
      }
      parent {
        ... on Mdx {
          body
          tableOfContents(maxDepth: 2)
          excerpt(truncate: true, pruneLength: 200)
        }
      }
    }
  }
`
