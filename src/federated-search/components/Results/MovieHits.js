import React from 'react'
import MovieCard from './MovieCard'
import { InfiniteHits } from 'react-instantsearch-hooks-web'

const MovieHits = () => {
  return (
    <div className="resultsContainer">
      <InfiniteHits
        hitComponent={MovieCard}
        showPrevious={false}
        classNames={{
          list: 'resultsList',
          item: 'card',
        }}
      />
    </div>
  )
}

export default MovieHits
