// React
import React from 'react'
// Gatsby
import { graphql, Link } from 'gatsby'
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
        keywords: page.keywords,
        description: page.description,
        ...page.parent.frontmatter,
        slug: page.slug,
        version: page.version.alias,
        edit_url: page.edit_url}}>
      <>
        <MDXProvider>
          <MDXRenderer>{page.parent.body}</MDXRenderer>
        </MDXProvider>
        {page.actions && (
          <>
            <h2>Actions</h2>
            <ul>
              {page.actions
                .sort((p1, p2) => p1.slug > p2.slug)
                .map( item => (
                  <li key={item.slug}>
                     <Link to={item.slug}>{item.name}</Link>
                  </li>
                )
              )}
            </ul>
          </>
        )}
      </>
    </Layout>
  )
}
export default Template

export const pageQuery = graphql`
  query($path: String!) {
    page: nikitaPackage(slug: { eq: $path }) {
      slug
      edit_url
      description
      keywords
      version {
        alias
      }
      parent {
        ... on Mdx {
          frontmatter {
            title
            titleHtml
          }
          body
        }
      }
      actions {
        name
        slug
      }
    }
  }
`
