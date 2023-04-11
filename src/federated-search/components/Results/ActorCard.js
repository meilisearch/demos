import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import styles from '../../styles/ActorCard.module.css'

const ActorCard = ({ hit }) => {
  let knownFor = true
  if (hit.known_for.length === 0) {
    knownFor = false
  }
  return (
    <>
    <div className={styles.actorMainInfo}>
      <div className={styles.pictureContainer}>
        <img
          src={hit.profile_path}
          alt={`${hit.name} picture`}
          className={styles.pictureImg}
        />
      </div>
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
        {
          knownFor ? 
          <div className={styles.extraData}>
              <div className={styles.knownFor}>Known for</div>
              <Highlight
                attribute="known_for"
                highlightedTagName="mark"
                hit={hit}
              />
          </div> 
          :
          ''
        }
    </>
  )
}

export default ActorCard
