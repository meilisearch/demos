import React from 'react'
import { InstantSearch, Index } from 'react-instantsearch-hooks-web'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import Header from '../components/Header'
import MovieResults from '../components/Results/MovieResults'
import ActorResults from '../components/Results/ActorResults'

const searchClient = instantMeiliSearch('http://localhost:7700', '')

const App = () => (
  <InstantSearch indexName="movies" searchClient={searchClient}>
    <Header />
    <div className="mainContainer centralWidth">
      <div className="leftPanel">
          <h2>Movies</h2>
          <MovieResults />
      </div>
      <div className="rightPanel">
        <Index indexName="actors">
          <h2>Actors</h2>
          <ActorResults />
        </Index>
      </div>
    </div>
  </InstantSearch>
)

export default App
