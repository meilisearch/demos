import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import Genre from './Genre'
import Director from './Director'
import Cast from './Cast'
import styles from '../../styles/MovieCard.module.css'

const MovieCard = ({ hit }) => {
  return (
    <>
      <div className={styles.movieMainInfo}>
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
            <Director crew={hit.crew} />
            <div>{hit.runtime} minutes</div>
            <div className={styles.genres}>
              <Genre genres={hit.genres} />
            </div>
          </div>
          <div className={styles.movieInfoTitle}>Cast</div>
          <Cast cast={hit.cast} />
        </div>
      </div>
      <div className={styles.extraData}>
        <Highlight attribute="overview" highlightedTagName="mark" hit={hit} />
      </div>
    </>
  )
}

export default MovieCard
