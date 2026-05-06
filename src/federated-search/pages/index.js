import React, { useState } from 'react'
import { InstantSearch, Index, Configure } from 'react-instantsearch-hooks-web'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import Header from '../components/Header'
import MovieResults from '../components/Results/MovieResults'
import ActorResults from '../components/Results/ActorResults'
import FederatedResults from '../components/Results/FederatedResults'
import ModeToggle from '../components/ModeToggle'

const searchClient = instantMeiliSearch(
  process.env.NEXT_PUBLIC_MEILISEARCH_HOST,
  process.env.NEXT_PUBLIC_MEILISEARCH_SEARCH_API_KEY
)

const App = () => {
  const [mode, setMode] = useState('multi')

  return (
    <InstantSearch indexName="moviesTmdb" searchClient={searchClient}>
      <Header />
      <div className="title">
        <h1>Meilisearch multi-search</h1>
        <p>Search across movies and actors with and without federation</p>
      </div>
      <ModeToggle mode={mode} onChange={setMode} />
      {mode === 'multi' ? (
        <div className="mainContainer centralWidth">
          <div className="leftPanel">
            <Configure hitsPerPage={10} />
            <h2>Movies</h2>
            <MovieResults />
          </div>
          <div className="rightPanel">
            <Index indexName="actorsTmdb">
              <Configure
                hitsPerPage={10}
                attributesToSnippet={['biography:80']}
              />
              <h2>Actors</h2>
              <ActorResults />
            </Index>
          </div>
        </div>
      ) : (
        <div className="centralWidth">
          <FederatedResults />
        </div>
      )}
    </InstantSearch>
  )
}

export default App
