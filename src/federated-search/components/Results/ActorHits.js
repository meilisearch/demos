import React from 'react'
import ActorCard from './ActorCard'
import { InfiniteHits } from 'react-instantsearch-hooks-web'

const ActorHits = () => {
  const transformActorsItems = items => {
    return items.map(item => ({
      ...item,
      _highlightResult: {
        ...item._highlightResult,
        known_for: item?._highlightResult?.known_for?.reduce((acc, curr) => {
          if (curr?.original_title) {
            acc.push(curr.original_title)
            return acc
          }
          return acc
        }, []),
      },
    }))
  }
  return (
    <div className="resultsContainer">
      <InfiniteHits
        hitComponent={ActorCard}
        showPrevious={false}
        transformItems={transformActorsItems}
        classNames={{
          list: 'resultsList',
          item: 'card',
        }}
      />
    </div>
  )
}

export default ActorHits
