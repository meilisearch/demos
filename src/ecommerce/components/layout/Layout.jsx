import React from 'react'
import NavBar from './NavBar'
import Blur from './Blur'
import { InstantSearch } from 'react-instantsearch-dom'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'

const searchClient = instantMeiliSearch(
  process.env.NEXT_PUBLIC_MEILI_HOST_NAME,
  process.env.NEXT_PUBLIC_MEILI_API_KEY
)

const Layout = ({ children }) => {
  return (
    <InstantSearch indexName='products' searchClient={searchClient}>
      <Blur />
      <NavBar />
      <main>{children}</main>
    </InstantSearch>
  )
}

export default Layout
