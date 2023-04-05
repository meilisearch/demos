import React from 'react'
import { useInstantSearch } from 'react-instantsearch-hooks-web';
import NoResults from './NoResults'
import InfiniteHits from './InfiniteHits'

const Results = ({type}) => {
  const { results } = useInstantSearch();
  const hasResults = results.nbHits !== 0
  return (
    <React.Fragment>
      {hasResults ? <InfiniteHits type={type} /> : <NoResults />}
    </React.Fragment>
  )
}

export default Results
