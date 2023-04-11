import React from 'react'
import { useInstantSearch, InfiniteHits } from 'react-instantsearch-hooks-web'
import MovieCard from './MovieCard'
import NoResults from './NoResults'

const MovieResults = () => {
  const { results } = useInstantSearch()
  const hasResults = results.nbHits !== 0
  return (
    <React.Fragment>
      {hasResults ? 
        <div className="resultsContainer">
          <InfiniteHits
            hitComponent={MovieCard}
            showPrevious={false}
            classNames={{
              list: 'resultsList',
              item: 'card',
              loadMore: 'loadMoreButton'
            }}
          />
        </div>
      : 
      <NoResults />}
    </React.Fragment>
  )
}

export default MovieResults
