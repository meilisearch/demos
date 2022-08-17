import React from 'react'
import NavBar from './NavBar'
import { InstantSearch } from 'react-instantsearch-dom'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'

const searchClient = instantMeiliSearch(
  "https://ms-336e328523ff-106.lon.meilisearch.io",
  "b4b6d1b32716ac8680fce331770f8309c7476a15d11513665c552eb70b5b3e8d"
)

const Layout = ({ children }) => {
  return (
    <InstantSearch indexName="products" searchClient={searchClient}>
      <NavBar />
      <main>{children}</main>
    </InstantSearch>
  )
}

export default Layout
