import React from 'react'
import { InstantSearch, Index, Hits } from 'react-instantsearch-dom'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import SearchBar from '../components/SearchBar'
const searchClient = instantMeiliSearch(
  'http://localhost:7700',
  '',
  { keepZeroFacets: true }
)

const App = () => (
  <InstantSearch indexName="movies" searchClient={searchClient}>
    <SearchBar/>
    <Index indexName="movies">
      <h2>index: Movies</h2>
      <Hits />
    </Index>

    <Index indexName="actors">
      <h2>index: Actors</h2>
      <Hits />
    </Index>
  </InstantSearch>
)

export default App
