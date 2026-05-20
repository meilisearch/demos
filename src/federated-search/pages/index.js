import React, { useState, useEffect } from 'react'
import {
  InstantSearch,
  Index,
  Configure,
  useSearchBox,
} from 'react-instantsearch-hooks-web'
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

const QueryBridge = ({ query }) => {
  const { refine } = useSearchBox()
  useEffect(() => {
    refine(query)
  }, [query, refine])
  return null
}

const App = () => {
  const [mode, setMode] = useState('multi')
  const [query, setQuery] = useState('')

  return (
    <>
      <Header searchValue={query} onSearchChange={setQuery} />
      <div className="title">
        <h1>Meilisearch multi-search</h1>
        <p>Search across movies and actors with and without federation</p>
      </div>
      <ModeToggle mode={mode} onChange={setMode} />
      {mode === 'multi' ? (
        <InstantSearch indexName="moviesTmdb" searchClient={searchClient}>
          <QueryBridge query={query} />
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
        </InstantSearch>
      ) : (
        <div className="centralWidth">
          <FederatedResults query={query} />
        </div>
      )}
    </>
  )
}

export default App
