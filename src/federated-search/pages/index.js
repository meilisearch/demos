import React from 'react'
import { InstantSearch, Index, Configure } from 'react-instantsearch-hooks-web'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import Header from '../components/Header'
import MovieResults from '../components/Results/MovieResults'
import ActorResults from '../components/Results/ActorResults'

const searchClient = instantMeiliSearch(
  process.env.NEXT_PUBLIC_MEILISEARCH_HOST,
  process.env.NEXT_PUBLIC_MEILISEARCH_SEARCH_API_KEY
)

const App = () => (
  <InstantSearch indexName="moviesTmdb" searchClient={searchClient}>
    <Header />
    <div class="title">
      <h1>Federated search</h1>
      <p>
        Search across several indexes with Meilisearch&apos;s federated search
      </p>
    </div>
    <div className="mainContainer centralWidth">
      <div className="leftPanel">
        <Configure hitsPerPage={10} />
        <h2>Movies</h2>
        <MovieResults />
      </div>
      <div className="rightPanel">
        <Index indexName="actorsTmdb">
          <Configure hitsPerPage={10} attributesToSnippet={['biography:80']} />
          <h2>Actors</h2>
          <ActorResults />
        </Index>
      </div>
    </div>
  </InstantSearch>
)

export default App
