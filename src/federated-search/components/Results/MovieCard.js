import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import styles from '../../styles/MovieCard.module.css'

const MovieCard = ({ hit }) => {
  return (
    <div className={styles.card}>
      <div className={styles.posterContainer}>
        <img src={hit.poster_path} alt={`${hit.title} poster`} className={styles.posterImg}/>
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
          <div>
            {hit.runtime} minutes
          </div>
          <div className={styles.genres}>
          <Highlight
            attribute="genres"
            highlightedTagName="mark"
            hit={hit}
            className={styles.genres}
          />
        </div>
        </div>
        <div>
          <Highlight
            attribute="overview"
            highlightedTagName="mark"
            hit={hit}
            className={styles.overview}
          />
        </div>
      </div>
      <div className={styles.extraDataContainer}>
        <div className={styles.cast}>
          <p>Cast</p>

        </div>
      </div>
    </div>
  )
}

export default MovieCard
