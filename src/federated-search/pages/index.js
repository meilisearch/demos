import React from 'react'
import { InstantSearch, Index } from 'react-instantsearch-hooks-web';
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import Header from '../components/Header';
import Results from '../components/Results'
const searchClient = instantMeiliSearch(
  'http://localhost:7700',
  '',
  { keepZeroFacets: true }
)

const App = () => (
  <InstantSearch indexName="movies" searchClient={searchClient}>
    <Header/>
    <div className='mainContainer centralWidth'>
      <div className='leftPanel'>
        <Index indexName="movies">
          <h2>Movies</h2>
          <Results type='movie' />
        </Index>
      </div>
      <div className='rightPanel'>
        <Index indexName="actors">
          <h2>Actors</h2>
          <Results type='actor' />
        </Index>
      </div>
    </div>
  </InstantSearch>
)

export default App
