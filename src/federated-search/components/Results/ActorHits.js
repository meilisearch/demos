import React from 'react'
import ActorCard from './ActorCard'
import { InfiniteHits } from 'react-instantsearch-hooks-web'

const ActorHits = () => {
  return (
    <div className="resultsContainer">
      <InfiniteHits
        hitComponent={ActorCard}
        showPrevious={false}
        classNames={{
          list: 'resultsList',
          item: 'card',
        }}
      />
    </div>
  )
}

export default ActorHits
