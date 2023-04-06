import React from 'react'
import { useInstantSearch } from 'react-instantsearch-hooks-web'
import NoResults from './NoResults'
import MovieHits from './MovieHits'

const MovieResults = () => {
  const { results } = useInstantSearch()
  const hasResults = results.nbHits !== 0
  return (
    <React.Fragment>
      {hasResults ? <MovieHits /> : <NoResults />}
    </React.Fragment>
  )
}

export default MovieResults
