import React from 'react'
import MovieCard from './MovieCard'
import ActorCard from './ActorCard'
import { useInfiniteHits } from 'react-instantsearch-hooks-web';
import styles from '../../styles/Results.module.css'

const InfiniteHits = (props) => {
  let movie = true
  if (props.type !== 'movie') {
    movie = false
  }
  const {
    hits,
    isLastPage, 
    showMore,
  } = useInfiniteHits(props);

  return (
    <div className={styles.resultsContainer}>
      <ul className={styles.resultsList}>
        {hits.map((hit, index) => (

          movie ?
          <MovieCard key={index} hit={hit} /> 
          :
          <ActorCard key={index} hit={hit} /> 
        ))}
      </ul>
      <button
        disabled={isLastPage}
        onClick={showMore}
        className="ais-InfiniteHits-loadMore"
      >
        Show more
      </button>
    </div>
  );
}
export default InfiniteHits;
