import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import styles from '../../styles/MovieCard.module.css'

const MovieCard = ({ hit }) => {
  return (
    <>
      <div className={styles.posterContainer}>
        <img
          src={hit.poster_path}
          alt={`${hit.title} poster`}
          className={styles.posterImg}
        />
      </div>
      <div className={styles.movieMainInfoContainer}>
        <div className={styles.movieHeading}>
          <div>
            <Highlight
              attribute="title"
              highlightedTagName="mark"
              hit={hit}
              className={styles.title}
            />
          </div>
          <div>{hit.runtime} minutes</div>
          <div>
            <Highlight attribute="genres" highlightedTagName="mark" hit={hit} />
          </div>
        </div>
        <div>
          <Highlight attribute="overview" highlightedTagName="mark" hit={hit} />
        </div>
      </div>
    </>
  )
}

export default MovieCard
