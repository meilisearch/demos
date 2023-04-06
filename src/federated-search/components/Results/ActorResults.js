import React from 'react'
import { useInstantSearch } from 'react-instantsearch-hooks-web'
import NoResults from './NoResults'
import ActorHits from './ActorHits'

const ActorResults = () => {
  const { results } = useInstantSearch()
  const hasResults = results.nbHits !== 0
  return (
    <React.Fragment>
      {hasResults ? <ActorHits /> : <NoResults />}
    </React.Fragment>
  )
}

export default ActorResults
