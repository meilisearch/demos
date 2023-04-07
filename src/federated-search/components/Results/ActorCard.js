import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import styles from '../../styles/ActorCard.module.css'

const ActorCard = ({ hit }) => {
  return (
    <>
      <div className={styles.pictureContainer}>
        <img
          src={hit.profile_path}
          alt={`${hit.name} picture`}
          className={styles.pictureImg}
        />
      </div>
      <div className={styles.actorMainInfoContainer}>
        <div className={styles.actorHeading}>
          <div>
            <Highlight
              attribute="name"
              highlightedTagName="mark"
              hit={hit}
              className={styles.name}
            />
          </div>
        </div>
        <div>
          <Highlight
            attribute="biography"
            highlightedTagName="mark"
            hit={hit}
            className={styles.biography}
          />
        </div>
      </div>
      <div className={styles.extraDataContainer}>
        <div className={styles.known_for}>
          <p>
            <span>Known for: </span>
            <Highlight
              attribute="known_for"
              highlightedTagName="mark"
              hit={hit}
            />
          </p>
        </div>
      </div>
    </>
  )
}

export default ActorCard
