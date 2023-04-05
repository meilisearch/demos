import React from 'react'
import { InstantSearch, Index } from 'react-instantsearch-hooks-web';
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import SearchBar from '../components/SearchBar'
import Results from '../components/Results'
const searchClient = instantMeiliSearch(
  'http://localhost:7700',
  '',
  { keepZeroFacets: true }
)

const App = () => (
  <InstantSearch indexName="movies" searchClient={searchClient}>
    <SearchBar/>
    <div className='mainContainer'>
      <div className='leftPanel'>
        <Index indexName="movies">
          <h2>index: Movies</h2>
          <Results type='movie' />
        </Index>
      </div>
      <div className='rightPanel'>
        <Index indexName="actors">
          <h2>index: Actors</h2>
          <Results type='actor' />
        </Index>
      </div>
    </div>
  </InstantSearch>
)

export default App
