import React from 'react'
import { useInstantSearch, InfiniteHits } from 'react-instantsearch-hooks-web'
import NoResults from './NoResults'
import ActorCard from './ActorCard'

const ActorResults = () => {
  const { results } = useInstantSearch()
  const hasResults = results.nbHits !== 0
  return (
    <React.Fragment>
      {hasResults ? 
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
      : 
      <NoResults />}
    </React.Fragment>
  )
}

export default ActorResults
