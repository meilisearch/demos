import React from 'react'
import Genre from './Genre'
import Director from './Director'
import styles from '../../styles/FederatedHit.module.css'

const Hl = ({ html }) => (
  <span dangerouslySetInnerHTML={{ __html: html || '' }} />
)

const MovieHit = ({ hit }) => {
  const fmt = hit._formatted || {}
  return (
    <>
      <div className={styles.mainInfo}>
        {hit.poster_path && (
          <img
            src={hit.poster_path}
            alt={`${hit.title} poster`}
            className={styles.image}
          />
        )}
        <div className={styles.info}>
          <span className={styles.title}>
            <Hl html={fmt.title || hit.title} />
          </span>
          <Director crew={hit.crew} />
          {hit.runtime && <div>{hit.runtime} min</div>}
          <div className={styles.genres}>
            <Genre genres={hit.genres} />
          </div>
        </div>
      </div>
      {fmt.overview && (
        <div className={styles.overview}>
          <Hl html={fmt.overview} />
        </div>
      )}
    </>
  )
}

const ActorHit = ({ hit }) => {
  const fmt = hit._formatted || {}
  const hasKnownFor = hit.known_for?.length > 0
  return (
    <div className={styles.mainInfo}>
      {hit.profile_path && (
        <img
          src={hit.profile_path}
          alt={`${hit.name} picture`}
          className={styles.image}
        />
      )}
      <div className={styles.info}>
        <span className={styles.title}>
          <Hl html={fmt.name || hit.name} />
        </span>
        {hasKnownFor && (
          <div>
            <div className={styles.label}>Known for</div>
            <Hl
              html={
                Array.isArray(fmt.known_for)
                  ? fmt.known_for.join(', ')
                  : fmt.known_for ||
                    (Array.isArray(hit.known_for)
                      ? hit.known_for.join(', ')
                      : hit.known_for)
              }
            />
          </div>
        )}
        {fmt.biography && (
          <div className={styles.overview}>
            <Hl html={fmt.biography} />
          </div>
        )}
      </div>
    </div>
  )
}

const FederatedHit = ({ hit }) => {
  const isMovie = hit._federation.indexUid === 'moviesTmdb'
  return (
    <div className={styles.card}>
      <span
        className={`${styles.badge} ${
          isMovie ? styles.movieBadge : styles.actorBadge
        }`}
      >
        {isMovie ? 'Movie' : 'Actor'}
      </span>
      {isMovie ? <MovieHit hit={hit} /> : <ActorHit hit={hit} />}
    </div>
  )
}

export default FederatedHit
