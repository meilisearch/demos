import React from 'react'
import Layout from '../components/Layout'

const NotFoundPage = ({ data }) => (
  <Layout
    page={{
      title: 'Page not found',
      description: 'The requested page does not exist',
      keywords: 'nikita, node.js, 404, not found'
    }}
  >
    <p>You just hit a route that doesn&#39;t exist... the sadness.</p>
  </Layout>
)

export default NotFoundPage
